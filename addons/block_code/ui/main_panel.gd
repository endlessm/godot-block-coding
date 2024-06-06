@tool
class_name MainPanel
extends Control

var eia: EditorInterfaceAccess

@onready var _picker: Picker = %Picker
@onready var _block_canvas: BlockCanvas = %NodeBlockCanvas
@onready var _drag_manager: DragManager = %DragManager
#@onready var _node_canvas := %NodeCanvas
#@onready var _node_list: NodeList = %NodeList
@onready var _title_bar: TitleBar = %TitleBar

var _current_path: String
var _current_bsd: BlockScriptData


func _ready():
	_picker.block_picked.connect(_drag_manager.copy_picked_block_and_drag)
	_block_canvas.reconnect_block.connect(_drag_manager.connect_block_canvas_signals)
	_drag_manager.block_dropped.connect(save_script)
	_drag_manager.block_modified.connect(save_script)
	#_node_list.node_selected.connect(_title_bar.node_selected)
	#_title_bar.node_name_changed.connect(_node_list.on_node_name_changed)


func _on_button_pressed():
	pass


func switch_script(path: String, bsd: BlockScriptData):
	_current_path = path
	_current_bsd = bsd
	_picker.bsd_selected(bsd)
	_title_bar.bsd_selected(bsd)
	_block_canvas.bsd_selected(bsd)


func create_and_switch_script(path: String, bsd: BlockScriptData):
	switch_script(path, bsd)
	save_script()


func save_script():
	if _current_bsd == null:
		print("No script loaded to save.")
		return

	var block_trees := _block_canvas.get_canvas_block_trees()
	var script_text: String = _block_canvas.generate_script_from_current_window(_current_bsd.script_class_name, _current_bsd.script_inherits)
	var bsd := BlockScriptData.new(_current_bsd.script_class_name, _current_bsd.script_inherits, block_trees, script_text)
	var bsd_path := _current_path.replace(".gd", "_bsd.tres")
	var error: Error = ResourceSaver.save(bsd, bsd_path)

	if error == OK:
		print("Saved block script to " + bsd_path)
	else:
		print("Failed to create block script: " + str(error))

	var script := FileAccess.open(_current_path, FileAccess.WRITE)

	if script != null:
		script.store_string(script_text)
		script.close()

		print("Saved generated script to " + _current_path)
	else:
		print("Failed to save generated script.")


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
				_drag_manager.drag_ended()

	# HACK: play the topmost block
	if event is InputEventKey:
		if event.keycode == KEY_F and event.pressed:
			if _current_bsd:
				var script: String = _block_canvas.generate_script_from_current_window(_current_bsd.script_class_name, _current_bsd.script_inherits)

				print(script)
				print("Debug script! (not saved)")
