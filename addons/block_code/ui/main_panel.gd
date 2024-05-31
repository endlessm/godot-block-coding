@tool
class_name MainPanel
extends Control

var eia: EditorInterfaceAccess

@onready var _picker: Picker = %Picker
@onready var _block_canvas: BlockCanvas = %NodeBlockCanvas
@onready var _drag_manager: DragManager = %DragManager
@onready var _node_canvas := %NodeCanvas
@onready var _node_list: NodeList = %NodeList
@onready var _title_bar: TitleBar = %TitleBar


func _ready():
	eia = EditorInterfaceAccess.new()

	_picker.block_picked.connect(_drag_manager.copy_picked_block_and_drag)
	_node_list.node_selected.connect(_title_bar.node_selected)
	_title_bar.node_name_changed.connect(_node_list.on_node_name_changed)


func _on_button_pressed():
	eia.context_switcher_3d_button.visible = false


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
			var script: String = _block_canvas.generate_script_from_current_window()

			var path: String = "user://test_script.gd"
			var test_script := FileAccess.open(path, FileAccess.WRITE)
			test_script.store_string(script)
			test_script.close()

			print(script)
			print("Saved to " + path + "\n")
