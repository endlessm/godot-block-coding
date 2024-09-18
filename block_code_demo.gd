extends Control

@onready var _context := BlockEditorContext.get_default()

@onready var _block_code := %BlockCode


func _ready() -> void:
	#var block_script: BlockScriptSerialization = 
	#block_script.script_inherits = _get_custom_or_native_class(get_parent())
	#block_script.generated_script = new_block_script.generated_script.replace("INHERIT_DEFAULT", new_block_script.script_inherits)

	_context.set_block_code_node.call_deferred(_block_code)
