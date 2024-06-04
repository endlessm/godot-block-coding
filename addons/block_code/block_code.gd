@tool
extends EditorPlugin

const MainPanel := preload("res://addons/block_code/ui/main_panel.tscn")
var main_panel

var eia: EditorInterfaceAccess

var script_ok_button: Button
var script_ok_prev_connection: Dictionary

var block_code_tab: Button


func _enter_tree():
	main_panel = MainPanel.instantiate()
	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(main_panel)
	# Hide the main panel. Very much required.
	_make_visible(false)

	eia = EditorInterfaceAccess.new()

	# Setup block scripting environment
	block_code_tab = eia.Utils.find_child_by_name(eia.context_switcher, "Block Code")

	script_ok_button = eia.script_create_window.get_ok_button()
	script_ok_prev_connection = script_ok_button.pressed.get_connections()[0]
	script_ok_button.pressed.disconnect(script_ok_prev_connection.callable)
	script_ok_button.pressed.connect(_create_block_script)


func _create_block_script():
	block_code_tab.pressed.emit()
	eia.script_create_window.get_cancel_button().pressed.emit()
	var create_menus = eia.Utils.find_child_by_type(eia.script_create_window, "VBoxContainer")

	# Create files
	var path: String = create_menus.get_children()[0].get_children()[9].get_children()[0].text
	var inherits: String = create_menus.get_children()[0].get_children()[3].get_children()[0].text

	var bsd_path: String = path.replace(".gd", "_bsd.tres")
	var default_packed_scene = PackedScene.new()
	var split_path := path.split("/")
	var file_name := split_path[split_path.size() - 1].replace(".gd", "")
	var bsd: BlockScriptData = BlockScriptData.new(file_name, inherits, default_packed_scene)
	var error: Error = ResourceSaver.save(bsd, bsd_path)

	if error == OK:
		print("Saved to " + bsd_path)
	else:
		print("Failed to create block script: " + str(error))

	main_panel.create_and_switch_script(path, bsd)


func _exit_tree():
	if main_panel:
		main_panel.queue_free()

	# Exit block scripting environment
	script_ok_button.pressed.disconnect(_create_block_script)
	_reconnect_signal(script_ok_button.pressed, script_ok_prev_connection)


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
