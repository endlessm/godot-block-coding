@tool
## Common BlockExtension for scene group options.
extends BlockExtension

const OptionData = preload("res://addons/block_code/code_generation/option_data.gd")
const Util = preload("res://addons/block_code/ui/util.gd")


# Global groups are just project settings in the global_group group.
# ProjectSettings doesn't offer an API to get the project groups or to get all
# settings. Fortunately, settings are simply implemented as properties on the
# ProjectSettings object.
static func _add_global_groups(groups: Dictionary):
	for prop in ProjectSettings.get_property_list():
		var name: String = prop["name"]
		var parts := name.split("/", false, 1)
		if parts[0] == "global_group":
			groups[parts[1]] = null


# Add all the groups in a node and its children, ignoring internal _ prefixed
# groups.
static func _add_node_groups(groups: Dictionary, node: Node):
	for group in node.get_groups():
		if not group.begins_with("_"):
			groups[String(group)] = null

	for child in node.get_children():
		_add_node_groups(groups, child)


func _get_edited_scene_groups() -> Array[String]:
	var groups: Dictionary
	_add_global_groups(groups)

	var root := context_node.get_tree().edited_scene_root
	_add_node_groups(groups, root)

	var sorted_groups: Array[String]
	sorted_groups.assign(groups.keys())
	sorted_groups.sort()
	return sorted_groups


func _init():
	# FIXME: Only global group changes are monitored. Scene local groups should
	# also be monitored, but godot does not have any reasonable API to do that.
	ProjectSettings.settings_changed.connect(_on_project_settings_changed)


func _context_node_changed():
	# If the context node changed, the scene local groups need to be updated.
	changed.emit()


func get_defaults() -> Dictionary:
	if not context_node:
		return {}

	# The default groups are only needed in the editor.
	if not Util.node_is_part_of_edited_scene(context_node):
		return {}

	var groups: Array[String] = _get_edited_scene_groups()
	return {"group": OptionData.new(groups)}


func _on_project_settings_changed():
	# FIXME: The global groups should be cached and compared so that the
	# defaults are only changed when the global groups actually change.
	changed.emit()
