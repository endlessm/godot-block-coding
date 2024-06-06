@tool
class_name BlockCodePlugin
extends EditorPlugin

const MainPanel := preload("res://addons/block_code/ui/main_panel.tscn")
static var main_panel

var script_ok_button: Button
var script_ok_prev_connection: Dictionary
var prev_opened_script_idx: int


func _enter_tree():
	main_panel = MainPanel.instantiate()
	main_panel.undo_redo = get_undo_redo()

	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(main_panel)
	# Hide the main panel. Very much required.
	_make_visible(false)


func _exit_tree():
	if main_panel:
		main_panel.queue_free()


func _reconnect_signal(_signal: Signal, _data: Dictionary):
	_signal.connect(_data.callable, _data.flags)


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel:
		main_panel.visible = visible


func _get_plugin_name():
	return "Block Code"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
