@tool
class_name BlockCode
extends Node

@export var bsd: BlockScriptData = null
static var plugin


func _ready():
	if Engine.is_editor_hint():
		return

	_update_parent_script()


func _enter_tree():
	if not Engine.is_editor_hint():
		return

	# Create script
	if bsd == null:
		var new_bsd: BlockScriptData = load("res://addons/block_code/ui/bsd_templates/default_bsd.tres").duplicate(true)
		new_bsd.script_inherits = get_parent().call("get_class")  # For whatever reason this works instead of just .get_class :)
		new_bsd.generated_script = new_bsd.generated_script.replace("INHERIT_DEFAULT", new_bsd.script_inherits)
		bsd = new_bsd

	if plugin == null:
		plugin = ClassDB.instantiate("EditorPlugin")
		plugin.add_inspector_plugin(load("res://addons/block_code/inspector_plugin/block_script_inspector.gd").new())


func _update_parent_script():
	if Engine.is_editor_hint():
		push_error("Updating the parent script must happen in game.")
		return

	var parent: Node = get_parent()
	var script := GDScript.new()
	script.set_source_code(bsd.generated_script)
	script.reload()
	parent.set_script(script)
	parent.set_process(true)


func _get_configuration_warnings():
	if bsd:
		if get_parent().call("get_class") != bsd.script_inherits:
			return ["The parent is not a %s. Create a new BlockCode node and reattach." % bsd.script_inherits]
