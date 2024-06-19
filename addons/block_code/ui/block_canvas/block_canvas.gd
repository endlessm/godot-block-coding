@tool
class_name BlockCanvas
extends MarginContainer

const EXTEND_MARGIN: float = 800

@onready var _window: Control = %Window
@onready var _window_scroll: ScrollContainer = %WindowScroll
@onready var _choose_block_code_label: Label = %ChooseBlockCodeLabel
@onready var _create_block_code_label: Label = %CreateBlockCodeLabel

var _block_scenes_by_class = {}

signal reconnect_block(block: Block)


func _ready():
	_populate_block_scenes_by_class()


func _populate_block_scenes_by_class():
	for _class in ProjectSettings.get_global_class_list():
		if not _class.base.ends_with("Block"):
			continue
		var _script = load(_class.path)
		if not _script.has_method("get_scene_path"):
			continue
		_block_scenes_by_class[_class.class] = _script.get_scene_path()


func add_block(block: Block) -> void:
	block.position.y += _window_scroll.scroll_vertical
	_window.add_child(block)
	_window.custom_minimum_size.y = max(block.position.y + EXTEND_MARGIN, _window.custom_minimum_size.y)


func set_child(n: Node):
	n.owner = _window
	for c in n.get_children():
		set_child(c)


func bsd_selected(bsd: BlockScriptData):
	clear_canvas()

	_choose_block_code_label.visible = false
	_create_block_code_label.visible = false

	if not bsd and scene_has_bsd_nodes():
		_choose_block_code_label.visible = true
		return
	elif not bsd and not scene_has_bsd_nodes():
		_create_block_code_label.visible = true
		return

	for tree in bsd.block_trees.array:
		load_tree(_window, tree)


func scene_has_bsd_nodes() -> bool:
	var scene_root = EditorInterface.get_edited_scene_root()
	if not scene_root:
		return false
	return scene_root.find_children("*", "BlockCode").size() > 0


func clear_canvas():
	for child in _window.get_children():
		child.queue_free()


func load_tree(parent: Node, node: SerializedBlockTreeNode):
	var _block_scene_path = _block_scenes_by_class[node.serialized_block.block_class]
	var scene: Block = load(_block_scene_path).instantiate()
	for prop_pair in node.serialized_block.serialized_props:
		scene.set(prop_pair[0], prop_pair[1])

	scene.on_canvas = true
	parent.add_child(scene)

	var scene_block: Block = scene as Block
	reconnect_block.emit(scene_block)

	for c in node.path_child_pairs:
		load_tree(scene.get_node(c[0]), c[1])


func get_canvas_block_trees() -> SerializedBlockTreeNodeArray:
	var block_trees := SerializedBlockTreeNodeArray.new()
	for c in _window.get_children():
		block_trees.array.append(build_tree(c))

	return block_trees


func build_tree(block: Block) -> SerializedBlockTreeNode:
	var n = SerializedBlockTreeNode.new()
	n.serialized_block = SerializedBlock.new(block.get_block_class(), block.get_serialized_props())

	for snap in find_snaps(block):
		for c in snap.get_children():
			if c is Block:  # Make sure to not include preview
				n.path_child_pairs.append([block.get_path_to(snap), build_tree(c)])

	return n


func find_snaps(node: Node) -> Array:
	var snaps := []

	if node.is_in_group("snap_point"):
		snaps.append(node)
	else:
		for c in node.get_children():
			snaps.append_array(find_snaps(c))

	return snaps
