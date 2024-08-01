extends Object


## Polyfill of Node.is_part_of_edited_scene(), available to GDScript in Godot 4.3+.
static func node_is_part_of_edited_scene(node: Node) -> bool:
	if not Engine.is_editor_hint():
		return false

	var tree := node.get_tree()
	if not tree or not tree.edited_scene_root:
		return false

	var edited_scene_parent := tree.edited_scene_root.get_parent()
	return edited_scene_parent and edited_scene_parent.is_ancestor_of(node)


## Get the nearest Block node that is a parent of the provided node.
static func get_parent_block(node: Node) -> Block:
	var parent = node.get_parent()
	while parent and not parent is Block:
		parent = parent.get_parent()
	return parent as Block
