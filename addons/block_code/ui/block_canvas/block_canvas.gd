@tool
extends MarginContainer

const ASTList = preload("res://addons/block_code/code_generation/ast_list.gd")
const BlockAST = preload("res://addons/block_code/code_generation/block_ast.gd")
const BlockCodePlugin = preload("res://addons/block_code/block_code_plugin.gd")
const BlockTreeUtil = preload("res://addons/block_code/ui/block_tree_util.gd")
const DragManager = preload("res://addons/block_code/drag_manager/drag_manager.gd")
const ScriptGenerator = preload("res://addons/block_code/code_generation/script_generator.gd")
const Util = preload("res://addons/block_code/ui/util.gd")

const EXTEND_MARGIN: float = 800
const BLOCK_AUTO_PLACE_MARGIN: Vector2 = Vector2(25, 8)
const DEFAULT_WINDOW_MARGIN: Vector2 = Vector2(25, 25)
const SNAP_GRID: Vector2 = Vector2(25, 25)
const ZOOM_FACTOR: float = 1.1

@onready var _context := BlockEditorContext.get_default()

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
@onready var _zoom_button: Button = %ZoomButton

var _current_block_script: BlockScriptSerialization
var _current_ast_list: ASTList
var _panning := false
var zoom: float:
	set(value):
		_window.scale = Vector2(value, value)
		_zoom_button.text = "%.1fx" % value
	get:
		return _window.scale.x

signal reconnect_block(block: Block)
signal add_block_code
signal open_scene
signal replace_block_code


func _ready():
	_context.changed.connect(_on_context_changed)

	if not _open_scene_button.icon and not Util.node_is_part_of_edited_scene(self):
		_open_scene_button.icon = _open_scene_icon


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if _context.block_code_node == null or _context.parent_node == null:
		return false
	if typeof(data) != TYPE_DICTIONARY:
		return false

	var nodes: Array = data.get("nodes", [])
	if nodes.size() != 1:
		return false
	var abs_path: NodePath = nodes[0]

	# Don't allow dropping BlockCode nodes or nodes that aren't part of the
	# edited scene.
	var node := get_tree().root.get_node(abs_path)
	if node is BlockCode or not Util.node_is_part_of_edited_scene(node):
		return false

	# Don't allow dropping the BlockCode node's parent as that's already self.
	var parent_path: NodePath = _context.parent_node.get_path()
	return abs_path != parent_path


func _drop_data(at_position: Vector2, data: Variant) -> void:
	var abs_path: NodePath = data.get("nodes", []).pop_back()
	if abs_path == null:
		return

	# Figure out the best path to the node.
	var node := get_tree().root.get_node(abs_path)
	var node_path: NodePath = Util.node_scene_path(node, _context.parent_node)
	if node_path in [^"", ^"."]:
		return

	var block = _context.block_script.instantiate_block_by_name(&"get_node")
	block.set_parameter_values_on_ready({"path": node_path})
	add_block(block, at_position)
	reconnect_block.emit(block)


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


func _on_context_changed():
	clear_canvas()

	var edited_node = EditorInterface.get_inspector().get_edited_object() as Node

	if _context.block_script != _current_block_script:
		_window.position = Vector2(0, 0)
		zoom = 1

	_window.visible = false
	_zoom_button.visible = false

	_empty_box.visible = false
	_selected_node_box.visible = false
	_selected_node_with_block_code_box.visible = false
	_add_block_code_button.disabled = true
	_open_scene_button.disabled = true
	_replace_block_code_button.disabled = true

	if _context.block_script != null:
		_load_block_script(_context.block_script)
		_window.visible = true
		_zoom_button.visible = true

		if _context.block_script != _current_block_script:
			reset_window_position()
	elif edited_node == null:
		_empty_box.visible = true
	elif BlockCodePlugin.node_has_block_code(edited_node):
		# If the selected node has a block code node, but BlockCodePlugin didn't
		# provide it to block_script_selected, we assume the block code itself is not
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

	_current_block_script = _context.block_script


func _load_block_script(block_script: BlockScriptSerialization):
	_current_ast_list = block_script.generate_ast_list()
	reload_ui_from_ast_list()


func reload_ui_from_ast_list():
	for ast_pair in _current_ast_list.array:
		var root_block = ui_tree_from_ast_node(ast_pair.ast.root)
		root_block.position = ast_pair.canvas_position
		_window.add_child(root_block)


func ui_tree_from_ast_node(ast_node: BlockAST.ASTNode) -> Block:
	var block: Block = _context.block_script.instantiate_block(ast_node.data)

	# Args
	var parameter_values: Dictionary

	for arg_name in ast_node.arguments:
		var argument = ast_node.arguments[arg_name]
		if argument is BlockAST.ASTValueNode:
			var value_block = ui_tree_from_ast_value_node(argument)
			parameter_values[arg_name] = value_block
		else:  # Argument is not a node, but a user input value
			parameter_values[arg_name] = argument

	block.set_parameter_values_on_ready(parameter_values)

	# Children
	var current_block: Block = block

	var i: int = 0
	for c in ast_node.children:
		var child_block: Block = ui_tree_from_ast_node(c)

		if i == 0:
			current_block.child_snap.add_child(child_block)
		else:
			current_block.bottom_snap.add_child(child_block)

		current_block = child_block
		i += 1

	reconnect_block.emit(block)
	return block


func ui_tree_from_ast_value_node(ast_value_node: BlockAST.ASTValueNode) -> Block:
	var block: Block = _context.block_script.instantiate_block(ast_value_node.data)

	# Args
	var parameter_values: Dictionary

	for arg_name in ast_value_node.arguments:
		var argument = ast_value_node.arguments[arg_name]
		if argument is BlockAST.ASTValueNode:
			var value_block = ui_tree_from_ast_value_node(argument)
			parameter_values[arg_name] = value_block
		else:  # Argument is not a node, but a user input value
			parameter_values[arg_name] = argument

	block.set_parameter_values_on_ready(parameter_values)

	reconnect_block.emit(block)
	return block


func clear_canvas():
	for child in _window.get_children():
		_window.remove_child(child)
		child.queue_free()


func rebuild_ast_list():
	_current_ast_list.clear()

	for c in _window.get_children():
		if c is StatementBlock:
			var root: BlockAST.ASTNode = build_ast(c)
			var ast: BlockAST = BlockAST.new()
			ast.root = root
			_current_ast_list.append(ast, c.position)


func build_ast(block: Block) -> BlockAST.ASTNode:
	var ast_node := BlockAST.ASTNode.new()
	ast_node.data = block.definition

	var parameter_values := block.get_parameter_values()

	for arg_name in parameter_values:
		var arg_value = parameter_values[arg_name]
		if arg_value is Block:
			ast_node.arguments[arg_name] = build_value_ast(arg_value)
		else:
			ast_node.arguments[arg_name] = arg_value

	var children: Array[BlockAST.ASTNode] = []

	if block.child_snap:
		var child: Block = block.child_snap.get_snapped_block()

		while child != null:
			var child_ast_node := build_ast(child)
			child_ast_node.data = child.definition

			children.append(child_ast_node)
			if child.bottom_snap == null:
				child = null
			else:
				child = child.bottom_snap.get_snapped_block()

	ast_node.children = children

	return ast_node


func build_value_ast(block: ParameterBlock) -> BlockAST.ASTValueNode:
	var ast_node := BlockAST.ASTValueNode.new()
	ast_node.data = block.definition

	var parameter_values := block.get_parameter_values()

	for arg_name in parameter_values:
		var arg_value = parameter_values[arg_name]
		if arg_value is Block:
			ast_node.arguments[arg_name] = build_value_ast(arg_value)
		else:
			ast_node.arguments[arg_name] = arg_value

	return ast_node


func rebuild_block_serialization_trees():
	_context.block_script.update_from_ast_list(_current_ast_list)


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
			if scope == block.definition.code_template:
				valid = true
		else:
			var tree_scope := BlockTreeUtil.get_tree_scope(block)
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


func _gui_input(event):
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


func generate_script_from_current_window() -> String:
	return ScriptGenerator.generate_script(_current_ast_list, _context.block_script)


func _on_zoom_button_pressed():
	zoom = 1.0
	reset_window_position()
