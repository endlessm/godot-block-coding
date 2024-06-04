@tool
class_name BlockCanvas
extends MarginContainer

const EXTEND_MARGIN: float = 800

@onready var _window: Control = %Window
@onready var _window_scroll: ScrollContainer = %WindowScroll


func add_block(block: Block) -> void:
	block.position.y += _window_scroll.scroll_vertical
	_window.add_child(block)
	_window.custom_minimum_size.y = max(block.position.y + EXTEND_MARGIN, _window.custom_minimum_size.y)


func set_child(n: Node):
	n.owner = _window
	for c in n.get_children():
		set_child(c)


func clear_canvas():
	for child in _window.get_children():
		child.queue_free()


func load_canvas():
	var save: PackedSceneTreeNodeArray = ResourceLoader.load("user://test_canvas.tres")
	for tree in save.array:
		load_tree(_window, tree)


func load_tree(parent: Node, node: PackedSceneTreeNode):
	var scene = node.scene.instantiate()
	parent.add_child(scene)
	for c in node.children:
		load_tree(scene.get_node(c[0]), c[1])


func save_canvas():
	var save = PackedSceneTreeNodeArray.new()
	for c in _window.get_children():
		save.array.append(build_tree(c))

	var save_error := ResourceSaver.save(save, "user://test_canvas.tres")

	if save_error != OK:
		push_error("An error occurred while saving the scene to disk.")


func build_tree(node: Node) -> PackedSceneTreeNode:
	var n = PackedSceneTreeNode.new()

	var scene := PackedScene.new()
	scene.pack(node)

	n.scene = scene

	for snap in find_snaps(node):
		for c in snap.get_children():
			n.children.append([node.get_path_to(snap), build_tree(c)])

	return n


func find_snaps(node: Node) -> Array:
	var snaps := []

	if node.is_in_group("snap_point"):
		snaps.append(node)
	else:
		for c in node.get_children():
			snaps.append_array(find_snaps(c))

	return snaps
