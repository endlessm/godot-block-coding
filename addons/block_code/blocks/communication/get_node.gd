@tool
extends BlockExtension

const OptionData = preload("res://addons/block_code/code_generation/option_data.gd")
const Util = preload("res://addons/block_code/ui/util.gd")


func _find_paths(paths: Array[NodePath], node: Node, path_root: Node, block_parent: Node):
	# Add any non-BlockCode nodes that aren't the parent of the current
	# BlockCode node.
	if not node is BlockCode:
		var node_path: NodePath = Util.node_scene_path(node, block_parent, path_root)
		if not node_path in [^"", ^"."]:
			paths.append(node_path)

	for child in node.get_children():
		_find_paths(paths, child, path_root, block_parent)


func get_defaults_for_node(context_node: Node) -> Dictionary:
	# The default paths are only needed in the editor.
	if not Engine.is_editor_hint():
		return {}

	var scene_root: Node = EditorInterface.get_edited_scene_root()
	var path_root: Node = scene_root.get_parent()
	var paths: Array[NodePath]
	_find_paths(paths, scene_root, path_root, context_node)

	if not paths:
		return {}

	return {"path": OptionData.new(paths)}
