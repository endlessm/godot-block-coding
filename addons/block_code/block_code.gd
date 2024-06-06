@tool
extends EditorPlugin

const BLOCKS_MANAGER_NAME = "BlocksManager"
const BLOCKS_MANAGER_SCRIPT = "res://addons/block_code/blocks_manager.gd"

const MainPanel := preload("res://addons/block_code/ui/main_panel.tscn")
var main_panel

var eia: EditorInterfaceAccess

var script_ok_button: Button
var script_ok_prev_connection: Dictionary
var prev_opened_script_idx: int

var block_code_tab: Button
var _blocks_manager


func _ready():
	await get_tree().process_frame
	_blocks_manager = get_tree().root.find_child(BLOCKS_MANAGER_NAME, true, false)
	_attach_resources()


func _enter_tree():
	add_autoload_singleton(BLOCKS_MANAGER_NAME, BLOCKS_MANAGER_SCRIPT)

	if not Engine.is_editor_hint():
		return

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

	# Handle scene tree buttons to intercept block script open
	# eia.scene_tree.button_clicked.connect(_handle_scene_tree_button)


func _load_block_script_data(bsd_path: String) -> BlockScriptData:
	var bsd: BlockScriptData = ResourceLoader.load(bsd_path, "BlockScriptData", ResourceLoader.CACHE_MODE_IGNORE)
	if bsd:
		print("Loaded block script from " + bsd_path)
		return bsd

	print("Failed to load block script from " + bsd_path)
	return null


func _create_block_script():
	#prev_opened_script_idx = eia.script_editor_items.get_selected_items()[0]

	# Create actual script but close script editor window (Doesn't work atm, need to remove popup)
	script_ok_prev_connection.callable.call()
	#var new_script_idx = eia.script_editor_items.get_selected_items()[0]
	#print(eia.script_editor_items.get_item_text(new_script_idx))
	#eia.script_editor_items.remove_item(new_script_idx)
	#eia.script_editor_items.select(prev_opened_script_idx)
	#eia.script_editor_items.item_selected.emit(prev_opened_script_idx)

	# Find create script menu
	var create_menus = eia.Utils.find_child_by_type(eia.script_create_window, "VBoxContainer")

	var create_new := true

	# Create files
	var path: String = create_menus.get_children()[0].get_children()[9].get_children()[0].text
	var inherits: String = create_menus.get_children()[0].get_children()[3].get_children()[0].text

	var bsd_path: String = path.replace(".gd", "_bsd.tres")
	if FileAccess.file_exists(bsd_path):
		create_new = false

	if create_new:
		var default_block_trees = preload("res://addons/block_code/ui/bsd_templates/default_bsd.tres")
		var split_path := path.split("/")
		var file_name := split_path[split_path.size() - 1].replace(".gd", "")
		var bsd: BlockScriptData = BlockScriptData.new(file_name, inherits, default_block_trees)
		bsd.source_code_dirty.connect(_on_bsd_source_code_dirty)

		main_panel.create_and_switch_script(bsd_path, bsd)
	else:
		var bsd := _load_block_script_data(bsd_path)
		bsd.source_code_dirty.connect(_on_bsd_source_code_dirty)

		main_panel.switch_script(bsd_path, bsd)

	block_code_tab.pressed.emit()


func _on_bsd_source_code_dirty():
	print("dirty!")


func _open_block_script(path: String, bsd_path: String):
	var bsd := _load_block_script_data(bsd_path)
	main_panel.switch_script(bsd_path, bsd)
	block_code_tab.pressed.emit()


func _handle_scene_tree_button(tree_item, column, id, mouse_button_index):
	if not is_instance_valid(tree_item):
		return

	var button_index = tree_item.get_button_by_id(column, id)

	# Get path from tooltip
	var tooltip: String = tree_item.get_button_tooltip_text(column, button_index)
	if tooltip.begins_with("Open Script"):
		var path: String = tooltip.replace("Open Script: ", "")
		var bsd_path := path.replace(".gd", "_bsd.tres")
		_open_block_script(path, bsd_path)


#func recurse_tree(tree_item: TreeItem, method: Callable):
#method.call(tree_item)
#for c in tree_item.get_children():
#recurse_tree(c, method)


func _exit_tree():
	remove_autoload_singleton(BLOCKS_MANAGER_NAME)

	if main_panel:
		main_panel.queue_free()

	# Exit block scripting environment
	script_ok_button.pressed.disconnect(_create_block_script)
	_reconnect_signal(script_ok_button.pressed, script_ok_prev_connection)

	# eia.scene_tree.button_clicked.disconnect(_handle_scene_tree_button)


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


func _attach_resources():
	if not _blocks_manager:
		print("no blocks manager")
		return
	_blocks_manager.attach_resources()
