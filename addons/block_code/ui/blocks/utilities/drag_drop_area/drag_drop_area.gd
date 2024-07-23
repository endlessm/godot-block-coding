@tool
extends MarginContainer

signal mouse_down
signal mouse_up


func _on_gui_input(event):
	if event is InputEventMouseButton and get_global_rect().has_point(event.global_position):
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			mouse_down.emit()
			get_viewport().set_input_as_handled()
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			mouse_up.emit()
			get_viewport().set_input_as_handled()
