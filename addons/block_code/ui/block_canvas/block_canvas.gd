@tool
class_name BlockCanvas
extends MarginContainer

const EXTEND_MARGIN: float = 800

@onready var _window: Control = %Window
@onready var _window_scroll: ScrollContainer = %WindowScroll

signal reconnect_block(block: Block)


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

	for tree in bsd.block_trees.array:
		load_tree(_window, tree)


func clear_canvas():
	for child in _window.get_children():
		child.queue_free()


#func load_canvas():
#var save: SerializedBlockTreeNodeArray = ResourceLoader.load("user://test_canvas.tres")
#for tree in save.array:
#load_tree(_window, tree)


func load_tree(parent: Node, node: SerializedBlockTreeNode):
	var scene: Block = load(node.serialized_block.block_path).instantiate()
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
	n.serialized_block = SerializedBlock.new(block.get_scene_path(), block.get_serialized_props())

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
