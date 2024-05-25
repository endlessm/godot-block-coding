@tool
class_name DragDropArea
extends MarginContainer

signal mouse_down
signal mouse_up

var hovered := false


func _on_mouse_entered():
	hovered = true


func _on_mouse_exited():
	hovered = false


func _on_gui_input(event):
	if hovered:
		if event is InputEventMouseButton:
			var mouse_event: InputEventMouseButton = event as InputEventMouseButton
			if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
				mouse_down.emit()
			if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
				mouse_up.emit()
