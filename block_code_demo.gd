extends Control

@onready var _context := BlockEditorContext.get_default()

@onready var _block_code := %BlockCode

@onready var MainPanel := %MainPanel

func _ready() -> void:
	if _block_code.block_script == null:
		var new_block_script: BlockScriptSerialization = load("res://addons/block_code/serialization/default_block_script.tres").duplicate(true)
		new_block_script.script_inherits = _block_code._get_custom_or_native_class(_block_code.get_parent())
		new_block_script.generated_script = new_block_script.generated_script.replace("INHERIT_DEFAULT", new_block_script.script_inherits)
		_block_code.block_script = new_block_script


	#_context.set_block_code_node.call_deferred(_block_code)
	await get_tree().process_frame
	MainPanel.switch_block_code_node(_block_code)
	MainPanel.script_window_requested.connect(script_window_requested)
	print("_block_code ", _block_code)

	var ShowScriptButton = MainPanel.get_node("%TitleBar").get_parent().get_node("ShowScriptButton")
	ShowScriptButton.text = "Load Block Code"

var showscriptwindowfirst = true
const ScriptWindow := preload("res://addons/block_code/ui/script_window/script_window.tscn")
func script_window_requested(scriptcontent):
	if showscriptwindowfirst:
		var script_window = ScriptWindow.instantiate()
		script_window.script_content = scriptcontent
		add_child(script_window)
		await script_window.close_requested
		script_window.queue_free()
		script_window = null

	var block_code_parent = _block_code.get_parent()
	var script := GDScript.new()
	script.set_source_code(scriptcontent)
	script.reload()
	block_code_parent.set_script(script)
	block_code_parent._ready()
	block_code_parent.set_process(true)
