@tool
class_name BlockCanvas
extends MarginContainer

const EXTEND_MARGIN: float = 800
const BLOCK_AUTO_PLACE_MARGIN: Vector2 = Vector2(25, 8)
const DEFAULT_WINDOW_MARGIN: Vector2 = Vector2(25, 25)
const SNAP_GRID: Vector2 = Vector2(25, 25)
const ZOOM_FACTOR: float = 1.1

@onready var _window: Control = %Window
@onready var _empty_box: BoxContainer = %EmptyBox

@onready var _selected_node_box: BoxContainer = %SelectedNodeBox
@onready var _selected_node_label: Label = %SelectedNodeBox/Label
@onready var _selected_node_label_format: String = _selected_node_label.text

@onready var _selected_node_with_block_code_box: BoxContainer = %SelectedNodeWithBlockCodeBox
@onready var _selected_node_with_block_code_label: Label = %SelectedNodeWithBlockCodeBox/Label
@onready var _selected_node_with_block_code_label_format: String = _selected_node_with_block_code_label.text

@onready var _add_block_code_button: Button = %AddBlockCodeButton
@onready var _open_scene_button: Button = %OpenSceneButton
@onready var _replace_block_code_button: Button = %ReplaceBlockCodeButton

@onready var _open_scene_icon = _open_scene_button.get_theme_icon("Load", "EditorIcons")

@onready var _mouse_override: Control = %MouseOverride
@onready var _zoom_label: Label = %ZoomLabel

var _current_bsd: BlockScriptData
var _block_scenes_by_class = {}
var _panning := false
var zoom: float:
	set(value):
		_window.scale = Vector2(value, value)
		_zoom_label.text = "%.1fx" % value
	get:
		return _window.scale.x

var _undo_redo: EditorUndoRedoManager

signal reconnect_block(block: Block)
signal add_block_code
signal open_scene
signal replace_block_code


func _ready():
	if not _open_scene_button.icon:
		_open_scene_button.icon = _open_scene_icon
	_populate_block_scenes_by_class()


func _populate_block_scenes_by_class():
	for _class in ProjectSettings.get_global_class_list():
		if not _class.base.ends_with("Block"):
			continue
		var _script = load(_class.path)
		if not _script.has_method("get_scene_path"):
			continue
		_block_scenes_by_class[_class.class] = _script.get_scene_path()


func add_block(block: Block, position: Vector2 = Vector2.ZERO) -> void:
	if block is EntryBlock:
		block.position = canvas_to_window(position).snapped(SNAP_GRID)
	else:
		block.position = canvas_to_window(position)

	_window.add_child(block)


func get_blocks() -> Array[Block]:
	var blocks: Array[Block] = []
	for child in _window.get_children():
		var block = child as Block
		if block:
			blocks.append(block)
	return blocks


func arrange_block(block: Block, nearby_block: Block) -> void:
	add_block(block)
	var rect = nearby_block.get_global_rect()
	rect.position += (rect.size * Vector2.RIGHT) + BLOCK_AUTO_PLACE_MARGIN
	block.global_position = rect.position


func set_child(n: Node):
	n.owner = _window
	for c in n.get_children():
		set_child(c)


func bsd_selected(bsd: BlockScriptData):
	clear_canvas()

	var edited_node = EditorInterface.get_inspector().get_edited_object() as Node

	_window.position = Vector2(0, 0)
	zoom = 1

	_window.visible = false
	_zoom_label.visible = false

	_empty_box.visible = false
	_selected_node_box.visible = false
	_selected_node_with_block_code_box.visible = false
	_add_block_code_button.disabled = true
	_open_scene_button.disabled = true
	_replace_block_code_button.disabled = true

	if bsd != null:
		_load_bsd(bsd)
		_window.visible = true
		_zoom_label.visible = true

		if bsd != _current_bsd:
			reset_window_position()
	elif edited_node == null:
		_empty_box.visible = true
	elif BlockCodePlugin.node_has_block_code(edited_node):
		# If the selected node has a block code node, but BlockCodePlugin didn't
		# provide it to bsd_selected, we assume the block code itself is not
		# editable. In that case, provide options to either edit the node's
		# scene file, or override the BlockCode node. This is mostly to avoid
		# creating a situation where a node has multiple BlockCode nodes.
		_selected_node_with_block_code_box.visible = true
		_selected_node_with_block_code_label.text = _selected_node_with_block_code_label_format.format({"node": edited_node.name})
		_open_scene_button.disabled = false if edited_node.scene_file_path else true
		_replace_block_code_button.disabled = false
	else:
		_selected_node_box.visible = true
		_selected_node_label.text = _selected_node_label_format.format({"node": edited_node.name})
		_add_block_code_button.disabled = false

	_current_bsd = bsd


func _load_bsd(bsd: BlockScriptData):
	for tree in bsd.block_trees.array:
		load_tree(_window, tree)


func scene_has_bsd_nodes() -> bool:
	var scene_root = EditorInterface.get_edited_scene_root()
	if not scene_root:
		return false
	return scene_root.find_children("*", "BlockCode").size() > 0


func clear_canvas():
	for child in _window.get_children():
		_window.remove_child(child)
		child.queue_free()


func load_tree(parent: Node, node: SerializedBlockTreeNode):
	var _block_scene_path = _block_scenes_by_class[node.serialized_block.block_class]
	var scene: Block = load(_block_scene_path).instantiate()
	for prop_pair in node.serialized_block.serialized_props:
		scene.set(prop_pair[0], prop_pair[1])
	parent.add_child(scene)

	var scene_block: Block = scene as Block
	reconnect_block.emit(scene_block)

	for c in node.path_child_pairs:
		load_tree(scene.get_node(c[0]), c[1])


func rebuild_block_trees(undo_redo):
	_undo_redo = undo_redo
	var block_trees_array = []
	for c in _window.get_children():
		block_trees_array.append(build_tree(c))
	undo_redo.add_undo_property(_current_bsd.block_trees, "array", _current_bsd.block_trees.array)
	undo_redo.add_do_property(_current_bsd.block_trees, "array", block_trees_array)


func build_tree(block: Block) -> SerializedBlockTreeNode:
	var path_child_pairs = []
	block.update_resources(_undo_redo)

	for snap in find_snaps(block):
		var snapped_block = snap.get_snapped_block()
		if snapped_block == null:
			continue
		path_child_pairs.append([block.get_path_to(snap), build_tree(snapped_block)])

	if block.resource.path_child_pairs != path_child_pairs:
		_undo_redo.add_undo_property(block.resource, "path_child_pairs", block.resource.path_child_pairs)
		_undo_redo.add_do_property(block.resource, "path_child_pairs", path_child_pairs)

	return block.resource


func find_snaps(node: Node) -> Array[SnapPoint]:
	var snaps: Array[SnapPoint]

	if node.is_in_group("snap_point") and node is SnapPoint:
		snaps.append(node)
	else:
		for c in node.get_children():
			snaps.append_array(find_snaps(c))

	return snaps


func set_scope(scope: String):
	for block in _window.get_children():
		var valid := false

		if block is EntryBlock:
			if scope == block.get_entry_statement():
				valid = true
		else:
			var tree_scope := DragManager.get_tree_scope(block)
			if tree_scope == "" or scope == tree_scope:
				valid = true

		if not valid:
			block.modulate = Color(0.5, 0.5, 0.5, 1)


func release_scope():
	for block in _window.get_children():
		block.modulate = Color.WHITE


func _on_add_block_code_button_pressed():
	_add_block_code_button.disabled = true

	add_block_code.emit()


func _on_open_scene_button_pressed():
	_open_scene_button.disabled = true

	open_scene.emit()


func _on_replace_block_code_button_pressed():
	_replace_block_code_button.disabled = true

	replace_block_code.emit()


func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SHIFT:
			set_mouse_override(event.pressed)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed and is_mouse_over():
				_panning = true
			else:
				_panning = false

		if event.button_index == MOUSE_BUTTON_MIDDLE:
			set_mouse_override(event.pressed)

		var relative_mouse_pos := get_global_mouse_position() - get_global_rect().position

		if is_mouse_over():
			var old_mouse_window_pos := canvas_to_window(relative_mouse_pos)

			if event.button_index == MOUSE_BUTTON_WHEEL_UP and zoom < 2:
				zoom *= ZOOM_FACTOR
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and zoom > 0.2:
				zoom /= ZOOM_FACTOR

			_window.position -= (old_mouse_window_pos - canvas_to_window(relative_mouse_pos)) * zoom

	if event is InputEventMouseMotion:
		if (Input.is_key_pressed(KEY_SHIFT) and _panning) or (Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) and _panning):
			_window.position += event.relative


func reset_window_position():
	var blocks = get_blocks()
	var top_left: Vector2 = Vector2.INF

	for block in blocks:
		if block.position.x < top_left.x:
			top_left.x = block.position.x
		if block.position.y < top_left.y:
			top_left.y = block.position.y

	if top_left == Vector2.INF:
		top_left = Vector2.ZERO

	_window.position = (-top_left + DEFAULT_WINDOW_MARGIN) * zoom


func canvas_to_window(v: Vector2) -> Vector2:
	return _window.get_transform().affine_inverse() * v


func window_to_canvas(v: Vector2) -> Vector2:
	return _window.get_transform() * v


func is_mouse_over() -> bool:
	return get_global_rect().has_point(get_global_mouse_position())


func set_mouse_override(override: bool):
	if override:
		_mouse_override.mouse_filter = Control.MOUSE_FILTER_PASS
		_mouse_override.mouse_default_cursor_shape = Control.CURSOR_MOVE
	else:
		_mouse_override.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_mouse_override.mouse_default_cursor_shape = Control.CURSOR_ARROW
