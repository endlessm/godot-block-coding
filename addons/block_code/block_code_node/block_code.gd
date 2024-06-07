@tool
class_name BlockCode
extends Node

var bsd: BlockScriptData = null:
	set = _set_block_script_data
static var plugin


func _set_block_script_data(new_bsd):
	print("set bsd", new_bsd)
	bsd = new_bsd
	if Engine.is_editor_hint():
		return
	if bsd == null:
		return
	if get_parent() == null:
		return
	bsd.changed.connect(_on_bsd_changed)

	# _attach_script_to_parent()


func _attach_script_to_parent():
	var parent: Node = get_parent()
	var script := GDScript.new()
	script.set_source_code(bsd.generated_script)
	script.reload()
	parent.set_script(script)
	parent.set_process(true)  # order these two differently
	parent.request_ready()
	print(bsd.generated_script)


func _ready():
	if Engine.is_editor_hint():
		return

	_attach_script_to_parent()


func _enter_tree():
	if not Engine.is_editor_hint():
		return

	# Check if we are in the block_code.tscn
	if get_tree().edited_scene_root.scene_file_path == "res://addons/block_code/block_code_node/block_code.tscn":
		return

	# Create script
	if bsd == null:
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


func code_changed():
	prints("code_changed", Engine.is_editor_hint())
	if Engine.is_editor_hint():
		return

	_attach_script_to_parent()


func _on_bsd_changed():
	print("changed!")
