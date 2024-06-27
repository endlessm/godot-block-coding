@tool
@icon("res://addons/block_code/block_code_node/block_code_node.svg")
class_name BlockCode
extends Node

@export var block_script: BlockScriptData = null
static var plugin


func _ready():
	if Engine.is_editor_hint():
		return

	_update_parent_script()


func _get_custom_or_native_class(node: Node):
	if node.has_method("get_custom_class"):
		return node.get_custom_class()
	return node.get_class()


func _enter_tree():
	if not Engine.is_editor_hint():
		return

	# Create script
	if block_script == null:
		var new_bsd: BlockScriptData = load("res://addons/block_code/ui/bsd_templates/default_bsd.tres").duplicate(true)
		new_bsd.script_inherits = _get_custom_or_native_class(get_parent())
		new_bsd.generated_script = new_bsd.generated_script.replace("INHERIT_DEFAULT", new_bsd.script_inherits)
		block_script = new_bsd

	if plugin == null:
		plugin = ClassDB.instantiate("EditorPlugin")
		plugin.add_inspector_plugin(load("res://addons/block_code/inspector_plugin/block_script_inspector.gd").new())


func _update_parent_script():
	if Engine.is_editor_hint():
		push_error("Updating the parent script must happen in game.")
		return

	var parent: Node = get_parent()
	var script := GDScript.new()
	script.set_source_code(block_script.generated_script)
	script.reload()

	# Persist export script variables (like SimpleCharacter exported texture)
	var persist_properties = {}
	var old_property_list = parent.get_property_list()
	for property in old_property_list:
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			persist_properties[property.name] = parent.get(property.name)

	parent.set_script(script)
	parent.set_process(true)

	# Set persisted script variables in new script
	for property_name in persist_properties:
		parent.set(property_name, persist_properties.get(property_name))

	# Run simple setup after node is ready
	if parent.has_method("simple_setup"):
		parent.call_deferred("simple_setup")


func _get_configuration_warnings():
	var warnings = []
	if block_script and _get_custom_or_native_class(get_parent()) != block_script.script_inherits:
		var warning = "The parent is not a %s. Create a new BlockCode node and reattach." % block_script.script_inherits
		warnings.append(warning)
	return warnings
