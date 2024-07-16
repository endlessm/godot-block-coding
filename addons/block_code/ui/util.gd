extends Object


## Polyfill of Node.is_part_of_edited_scene(), available to GDScript in Godot 4.3+.
static func node_is_part_of_edited_scene(node: Node) -> bool:
	return Engine.is_editor_hint() && node.is_inside_tree() && node.get_tree().edited_scene_root && node.get_tree().edited_scene_root.get_parent().is_ancestor_of(node)
