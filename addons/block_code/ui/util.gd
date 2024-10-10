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


## Get the path from [param reference] to [param node] within a scene.
##
## Returns the path from [param reference] to [param node] without referencing
## parent nodes. If [param node] is [param reference] or a child of it in the
## scene tree, a relative path is returned. If [param node] is an ancestor of
## [param reference] in the scene tree, an absolute path using [param
## path_root] is returned.
## [br]
## Both [param node] and [param reference] must be ancestors of [param
## path_root]. If [param path_root] is [constant null]
## [method EditorInterface.get_edited_scene_root().get_parent] is used.
static func node_scene_path(node: Node, reference: Node, path_root: Node = null) -> NodePath:
	if path_root == null:
		path_root = EditorInterface.get_edited_scene_root().get_parent()

	if not path_root.is_ancestor_of(node):
		push_error("Node %s is not an ancestor of %s" % [path_root, node])
		return NodePath()
	if not path_root.is_ancestor_of(reference):
		push_error("Node %s is not an ancestor of %s" % [path_root, reference])
		return NodePath()

	if node.unique_name_in_owner:
		# With unique_name_in_owner, just use the % prefixed name.
		return NodePath("%%%s" % node.name)
	else:
		# The node is reference or a child of it. Use a relative path.
		return reference.get_path_to(node)
