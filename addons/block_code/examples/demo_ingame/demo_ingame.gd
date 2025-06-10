extends Control

@onready var _context := BlockEditorContext.get_default()

@onready var block_code_node: BlockCode = %BlockCode
@onready var block_canvas: MarginContainer = %BlockCanvas
@onready var drag_manager: Control = %DragManager


func _ready() -> void:
	block_canvas.reconnect_block.connect(drag_manager.connect_block_canvas_signals)
	drag_manager.block_dropped.connect(save_script)
	drag_manager.block_modified.connect(save_script)
	_context.block_code_node = block_code_node


func _input(event):
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				# Release focus
				var focused_node := get_viewport().gui_get_focus_owner()
				if focused_node:
					focused_node.release_focus()
			else:
				drag_manager.drag_ended()


func save_script():
	if _context.block_code_node == null:
		print("No script loaded to save.")
		return

	var block_script: BlockScriptSerialization = _context.block_script
	block_canvas.rebuild_ast_list()
	block_canvas.rebuild_block_serialization_trees()
	var generated_script = block_canvas.generate_script_from_current_window()
	if generated_script != block_script.generated_script:
		block_script.generated_script = generated_script
		block_code_node._update_parent_script()
