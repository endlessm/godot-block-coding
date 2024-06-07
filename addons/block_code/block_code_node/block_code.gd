@tool
class_name BlockCode
extends Node

var bsd: BlockScriptData = null
static var plugin


func _ready():
	if Engine.is_editor_hint():
		return

	var parent: Node = get_parent()
	var script := GDScript.new()
	script.set_source_code(bsd.generated_script)
	script.reload()
	parent.set_script(script)
	parent.set_process(true)  # order these two differently
	parent.request_ready()


func _enter_tree():
	if not Engine.is_editor_hint():
		return

	# Create script
	if bsd == null:
		var old_bsd := bsd
		var new_bsd: BlockScriptData = load("res://addons/block_code/ui/bsd_templates/default_bsd.tres").duplicate()
		new_bsd.script_inherits = get_parent().call("get_class")  # For whatever reason this works instead of just .get_class :)
		new_bsd.generated_script = new_bsd.generated_script.replace("INHERIT_DEFAULT", new_bsd.script_inherits)
		bsd = new_bsd

	if plugin == null:
		plugin = ClassDB.instantiate("EditorPlugin")
		plugin.add_inspector_plugin(load("res://addons/block_code/inspector_plugin/block_script_inspector.gd").new())


# Necessary to "export" the block script data without exposing it
func _get_property_list():
	var properties = []

	(
		properties
		. append(
			{
				"name": "bsd",
				"type": BlockScriptData,
				"usage": PROPERTY_USAGE_NO_EDITOR,  # Store the property but don't appear in editor
			}
		)
	)

	return properties


func _get_configuration_warnings():
	if bsd:
		if get_parent().call("get_class") != bsd.script_inherits:
			return ["The parent is not a %s. Create a new BlockCode node and reattach." % bsd.script_inherits]
