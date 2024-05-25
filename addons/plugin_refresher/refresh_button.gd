@tool
extends Control

const PROJECT_METADATA_SECTION = "plugin_refresher"
const PROJECT_METADATA_KEY = "selected_plugin" 

const EDITOR_SETTINGS_NAME_PREFIX = "refresher_plugin/"
const EDITOR_SETTINGS_NAME_COMPACT = EDITOR_SETTINGS_NAME_PREFIX + "compact"
const EDITOR_SETTINGS_NAME_SHOW_ENABLE_MENU = EDITOR_SETTINGS_NAME_PREFIX + "show_enable_menu"
const EDITOR_SETTINGS_NAME_SHOW_SWITCH = EDITOR_SETTINGS_NAME_PREFIX + "show_switch"
const EDITOR_SETTINGS_NAME_SHOW_ON_OFF_TOGGLE = EDITOR_SETTINGS_NAME_PREFIX + "show_on_off_toggle"
const EDITOR_SETTINGS_NAME_SHOW_RESTART_BUTTON = EDITOR_SETTINGS_NAME_PREFIX + "show_restart_button"

var switch_icon := preload("plug_switch_icon.svg")
var list_icon := preload("plug_list_icon.svg")

@export var show_enable_menu: bool = true:
	set(value):
		show_enable_menu = value
		_update_children_visibility()
@export var show_switch: bool = true:
	set(value):
		show_switch = value
		_update_children_visibility()
@export var compact: bool = false:
	set(value):
		compact = value
		_update_switch_options_button_look()
@export var show_on_off_toggle: bool = true:
	set(value):
		show_on_off_toggle = value
		_update_children_visibility()
@export var show_restart_button: bool = true:
	set(value):
		show_restart_button = value
		_update_children_visibility()
@export var icon_next_to_plugin_name := true:
	set(value):
		icon_next_to_plugin_name = value
		_update_switch_options_button_look()

@onready var enable_menu := %enable_menu as MenuButton
@onready var switch_options := %switch_options as OptionButton
@onready var btn_toggle := %btn_toggle as CheckButton
@onready var reset_button := %reset_button as Button

var refresh_plugin : EditorPlugin

var plugin_folder := "res://addons/"

func _ready():
	refresh_plugin.main_screen_changed.connect(update_current_main_screen)
	refresh_plugin.get_editor_interface().get_editor_settings().settings_changed.connect(_load_settings)
	refresh_plugin.project_settings_changed.connect(_on_project_setting_changed)

	await get_tree().process_frame
	_update_plugins_list()
	
	enable_menu.icon = list_icon
	reset_button.icon = get_theme_icon(&"Reload", &"EditorIcons")
	
	_load_settings()

	enable_menu.about_to_popup.connect(_on_enable_menu_about_to_popup)
	enable_menu.get_popup().index_pressed.connect(_on_enable_menu_item_selected)
	switch_options.button_down.connect(_on_switch_options_button_down)
	switch_options.item_selected.connect(_on_switch_options_item_selected)
	btn_toggle.toggled.connect(_on_btn_toggle_toggled)
	reset_button.pressed.connect(_on_restart_button_pressed)
	
	_update_switch_options_button_look()
	_update_children_visibility()
	_update_button_states()

func _enter_tree():
	get_tree().create_timer(background_check_cycle_sec).timeout.connect(_background_check)

func _background_check():
#	if selected_plugin_index >= 0:
#		plugins[selected_plugin_index].deleted = not _plugin_exists(plugins[selected_plugin_index].directory)
#		if not plugins[selected_plugin_index].deleted:
#			_update_plugin_info_from_config(plugins[selected_plugin_index])
#	_update_plugin_states()
#	_update_switch_options_button_look()
#	_update_button_states()
	if is_inside_tree():
		get_tree().create_timer(background_check_cycle_sec).timeout.connect(_background_check)

func _load_settings():
	var current_main_screen = null
	compact = _get_editor_setting(EDITOR_SETTINGS_NAME_COMPACT, compact)
	show_enable_menu = _get_editor_setting(EDITOR_SETTINGS_NAME_SHOW_ENABLE_MENU, show_enable_menu)
	show_switch = _get_editor_setting(EDITOR_SETTINGS_NAME_SHOW_SWITCH, show_switch)
	show_on_off_toggle = _get_editor_setting(EDITOR_SETTINGS_NAME_SHOW_ON_OFF_TOGGLE, show_on_off_toggle)
	show_restart_button = _get_editor_setting(EDITOR_SETTINGS_NAME_SHOW_RESTART_BUTTON, show_restart_button)
	if not show_enable_menu and not show_switch:
		show_enable_menu = true
	if not show_on_off_toggle and not show_restart_button:
		show_on_off_toggle = true

var current_main_screen = null

func update_current_main_screen(s):
	if btn_toggle.button_pressed:
		current_main_screen = s

class PluginInfo:
	# No clue yet, how to better identify them, so for future proof id array is added here.
	# (If plugins moved around -> folder changes. However Godot identify them by folder name.)
	# Used internally by plug-in.
	var id: String
	var directory: String
	var last_known_file_date: int = -1
	var name: String
	var enabled: bool
	var deleted: bool

var plugins: Array[PluginInfo]

var selected_plugin_index := -1:
	set(value):
		selected_plugin_index = value
		_update_switch_options_button_look()
		_update_button_states()

@export var background_check_cycle_sec: float = 1

enum MenuAction {
	SHOW_SWITCH,
	COMPACT_VIEW,
	SHOW_ON_OFF_TOGGLE,
	SHOW_RESTART_BUTTON,
	SHOW_ENABLE_MENU
}

func _get_plugin_index_by_id(id: String) -> int:
	for i in plugins.size():
		if plugins[i].id == id: return i
	return -1
	
func _update_plugins_list():
	var previous_plugin_states := plugins.duplicate() as Array[PluginInfo]
	plugins.clear()
	_search_dir_for_plugins()
	for previous_plugin_state in previous_plugin_states:
		var already_in_list := false
		for plugin in plugins:
			if plugin.id == previous_plugin_state.id:
				already_in_list = true
				break
		if not already_in_list:
			previous_plugin_state.deleted = true
			plugins.append(previous_plugin_state)
	_update_plugin_states()

func _update_plugin_states(remove_disabled_and_deleted_ones: bool = false):
	var to_be_removed: Array[PluginInfo] = []
	for i in plugins.size():
		plugins[i].enabled = _is_plugin_enabled(i)
		if remove_disabled_and_deleted_ones and not plugins[i].enabled and plugins[i].deleted:
			to_be_removed.append(plugins[i])
	for plugin in to_be_removed:
		var i := plugins.find(plugin)
		if selected_plugin_index == i:
			selected_plugin_index = -1
			_set_project_metadata(PROJECT_METADATA_SECTION, PROJECT_METADATA_KEY, "")
		elif selected_plugin_index > i:
			selected_plugin_index -= 1
		plugins.remove_at(i)
	selected_plugin_index = _get_plugin_index_by_id(_get_project_metadata(PROJECT_METADATA_SECTION, PROJECT_METADATA_KEY, ""))

func _search_dir_for_plugins(relative_base_folder: String = ""):
	var path := plugin_folder.path_join(relative_base_folder)
	var dir := DirAccess.open(path)
	
	for subdir_name in dir.get_directories():
		var relative_folder = relative_base_folder.path_join(subdir_name)
		var subdir := DirAccess.open(path.path_join(subdir_name))
		if subdir == null: # Can happen for symlink. They are listed as folder, but if the link is broken, DirAccess returns null
			continue
		for file in subdir.get_files():
			if file == "plugin.cfg":
				if plugin_folder.path_join(relative_folder) == refresh_plugin.get_script().resource_path.get_base_dir():
					continue
				var plugin_info = PluginInfo.new()
				plugin_info.id = relative_folder
				plugin_info.directory = relative_folder
				_update_plugin_info_from_config(plugin_info)
				plugin_info.deleted = false
				plugins.append(plugin_info)
		_search_dir_for_plugins(relative_folder)

func _update_plugin_info_from_config(plugin_info: PluginInfo, force_load: bool = false):
	var path := plugin_folder.path_join(plugin_info.directory).path_join("plugin.cfg")
	if not force_load:
		if plugin_info.last_known_file_date == FileAccess.get_modified_time(path):
			return
	var plugincfg = ConfigFile.new()
	plugincfg.load(path)
	plugin_info.name = plugincfg.get_value("plugin", "name", "")
	plugin_info.last_known_file_date = FileAccess.get_modified_time(path)

func _plugin_exists(plugin_directory: String):
	var path := plugin_folder.path_join(plugin_directory).path_join("plugin.cfg")
	return FileAccess.file_exists(path)

func _on_project_setting_changed():
	_update_plugin_states()
	_update_button_states()

func _is_plugin_enabled(plugin_index: int) -> bool:
	return refresh_plugin.get_editor_interface().is_plugin_enabled(plugins[plugin_index].directory)

func _set_plugin_enabled(plugin_index: int, enabled: bool):
	refresh_plugin.get_editor_interface().set_plugin_enabled(plugins[plugin_index].directory, enabled)

func _get_editor_setting(name: String, default_value: Variant = null) -> Variant:
	if refresh_plugin.get_editor_interface().get_editor_settings().has_setting(name):
		return refresh_plugin.get_editor_interface().get_editor_settings().get_setting(name)
	else:
		return default_value

func _set_editor_setting(name: String, value: Variant):
	refresh_plugin.get_editor_interface().get_editor_settings().set_setting(name, value)
	
func _set_project_metadata(section: String, key: String, data: Variant):
	refresh_plugin.get_editor_interface().get_editor_settings().set_project_metadata(section, key, data)

func _get_project_metadata(section: String, key: String, default: Variant = null):
	return refresh_plugin.get_editor_interface().get_editor_settings().get_project_metadata(section, key, default)

func _update_enable_menu_popup():
	_update_plugins_list()
	
	var popup = enable_menu.get_popup()
	popup.clear()
	
	if plugins.size() > 0:
		var there_are_deleted_plugins := false
		for i in plugins.size():
			if not plugins[i].deleted:
				popup.add_check_item(plugins[i].name)
				popup.set_item_checked(popup.item_count - 1, _is_plugin_enabled(i))
				popup.set_item_metadata(popup.item_count - 1, plugins[i])
			else:
				if plugins[i].enabled:
					there_are_deleted_plugins = true
		if there_are_deleted_plugins:
			popup.add_separator("Deleted, but running")
			for i in plugins.size():
				if plugins[i].deleted and plugins[i].enabled:
					popup.add_check_item(plugins[i].name)
					popup.set_item_checked(popup.item_count - 1, _is_plugin_enabled(i))
					popup.set_item_metadata(popup.item_count - 1, plugins[i])
	else:
		popup.add_separator("No plugins")
	popup.add_separator()
	popup.add_item("Show quick switch" if not show_switch else "Hide quick switch")
	popup.set_item_metadata(popup.item_count - 1, MenuAction.SHOW_SWITCH)

func _update_switch_button_popup():
	_update_plugins_list()
	
	switch_options.clear()
	
	if plugins.size() > 0:
		var there_are_deleted_plugins := false
		var selected_option = -1
		for i in plugins.size():
			if not plugins[i].deleted:
				switch_options.add_item(plugins[i].name)
				switch_options.set_item_metadata(switch_options.item_count - 1, plugins[i])
				if i == selected_plugin_index:
					selected_option = switch_options.item_count - 1
			else:
				if plugins[i].enabled:
					there_are_deleted_plugins = true
		if there_are_deleted_plugins:
			switch_options.add_separator("Deleted, but running")
			for i in plugins.size():
				if plugins[i].deleted and plugins[i].enabled:
					switch_options.add_item(plugins[i].name)
					switch_options.set_item_metadata(switch_options.item_count - 1, plugins[i])
					if i == selected_plugin_index:
						selected_option = switch_options.item_count - 1
		switch_options.selected = selected_option
	else:
		switch_options.add_separator("No plugins")
		switch_options.selected = -1
	switch_options.add_separator()
	switch_options.get_popup().add_item("Set compact view" if not compact else "Show plug-in name")
	switch_options.set_item_metadata(switch_options.item_count - 1, MenuAction.COMPACT_VIEW)
	switch_options.get_popup().add_item("Show on/off toggle" if not show_on_off_toggle else "Hide on/off toggle")
	switch_options.set_item_metadata(switch_options.item_count - 1, MenuAction.SHOW_ON_OFF_TOGGLE)
	switch_options.get_popup().add_item("Show restart button" if not show_restart_button else "Hide restart button")
	switch_options.set_item_metadata(switch_options.item_count - 1, MenuAction.SHOW_RESTART_BUTTON)
	switch_options.add_separator()
	switch_options.get_popup().add_item("Show enable menu" if not show_enable_menu else "Hide enable menu")
	switch_options.set_item_metadata(switch_options.item_count - 1, MenuAction.SHOW_ENABLE_MENU)

func _process_menu_action(action: MenuAction) -> bool:
	var processed := true
	match action:
		MenuAction.SHOW_SWITCH:
			show_switch = !show_switch
			_set_editor_setting(EDITOR_SETTINGS_NAME_SHOW_SWITCH, show_switch)
		MenuAction.COMPACT_VIEW:
			compact = !compact
			_set_editor_setting(EDITOR_SETTINGS_NAME_COMPACT, compact)
		MenuAction.SHOW_ON_OFF_TOGGLE:
			show_on_off_toggle = !show_on_off_toggle
			_set_editor_setting(EDITOR_SETTINGS_NAME_SHOW_ON_OFF_TOGGLE, show_on_off_toggle)
			if not show_on_off_toggle and not show_restart_button:
				show_restart_button = true
				_set_editor_setting(EDITOR_SETTINGS_NAME_SHOW_RESTART_BUTTON, show_restart_button)
		MenuAction.SHOW_RESTART_BUTTON:
			show_restart_button = !show_restart_button
			_set_editor_setting(EDITOR_SETTINGS_NAME_SHOW_RESTART_BUTTON, show_restart_button)
			if not show_restart_button and not show_on_off_toggle:
				show_on_off_toggle = true
				_set_editor_setting(EDITOR_SETTINGS_NAME_SHOW_ON_OFF_TOGGLE, show_on_off_toggle)
		MenuAction.SHOW_ENABLE_MENU:
			show_enable_menu = !show_enable_menu
			_set_editor_setting(EDITOR_SETTINGS_NAME_SHOW_ENABLE_MENU, show_enable_menu)
		_:
			processed = false
	return processed

func _on_enable_menu_about_to_popup():
	_update_enable_menu_popup()

func _on_enable_menu_item_selected(index):
	var metadata = enable_menu.get_popup().get_item_metadata(index)
	if metadata is PluginInfo:
		var plugin_index = _get_plugin_index_by_id((metadata as PluginInfo).id)
		_set_plugin_enabled(plugin_index, !_is_plugin_enabled(plugin_index))
	else:
		_process_menu_action(metadata)

func _on_switch_options_button_down():
	_update_switch_button_popup()
	_update_switch_options_button_look()

func _on_btn_toggle_toggled(button_pressed):
	var current_main_screen_bkp = current_main_screen
	
	if selected_plugin_index >= 0:
		_set_plugin_enabled(selected_plugin_index, button_pressed)
	
	if button_pressed:
		if current_main_screen_bkp:
			refresh_plugin.get_editor_interface().set_main_screen_editor(current_main_screen_bkp)
			
func _on_restart_button_pressed():
	if _is_plugin_enabled(selected_plugin_index):
		_set_plugin_enabled(selected_plugin_index, false)
	_set_plugin_enabled(selected_plugin_index, true)

func _on_switch_options_item_selected(index):
	var metadata = switch_options.get_item_metadata(index)
	if metadata is PluginInfo:
		var plugin_index = _get_plugin_index_by_id((metadata as PluginInfo).id)
		_set_project_metadata(PROJECT_METADATA_SECTION, PROJECT_METADATA_KEY, plugins[switch_options.selected].id)
		auto_enable = false
		if selected_plugin_index >= plugins.size():
			selected_plugin_index = -1
		else:
			selected_plugin_index = index
		_update_switch_options_button_look()
		_update_button_states()
	else:
		_process_menu_action(metadata)

func _update_children_visibility():
	if enable_menu != null:
		enable_menu.visible = show_enable_menu
	if switch_options != null:
		switch_options.visible = show_switch
	if btn_toggle != null:
		btn_toggle.visible = show_switch and show_on_off_toggle
	if reset_button != null:
		reset_button.visible = show_switch and show_restart_button

var auto_enable: bool = false

func _update_button_states():
	if refresh_plugin != null and selected_plugin_index >= 0:
		var plugin_enabled = _is_plugin_enabled(selected_plugin_index)
		var plugin_exists = not plugins[selected_plugin_index].deleted
		if btn_toggle.button_pressed != plugin_enabled:
			btn_toggle.set_pressed_no_signal(plugin_enabled)
		btn_toggle.disabled = plugins[selected_plugin_index].deleted and not plugin_enabled
		btn_toggle.tooltip_text = ("Disable" if plugin_enabled else "Enable" if plugin_exists else "Cannot enabled deleted ") \
			+ " " + plugins[selected_plugin_index].name \
			+ "\n(Select plugin on the left)"
		reset_button.disabled = plugins[selected_plugin_index].deleted and not plugin_enabled
		reset_button.tooltip_text = ("Restart" if plugin_enabled else "Start" if plugin_exists else "Cannot start deleted ") \
			+ " " + plugins[selected_plugin_index].name \
			+ "\n(Select plugin on the left)"
	else:
		var tooltip_text = "No plugin selected" \
			+ "\n(Select plugin on the left)"
		btn_toggle.set_pressed_no_signal(false)
		btn_toggle.disabled = true
		btn_toggle.tooltip_text = tooltip_text
		reset_button.disabled = true
		reset_button.tooltip_text = tooltip_text

func _update_switch_options_button_look():
	if compact:
		switch_options.text = ""
		switch_options.icon = switch_icon
	else:
		if selected_plugin_index >= 0:
			switch_options.text = plugins[selected_plugin_index].name
			switch_options.icon = switch_icon if icon_next_to_plugin_name else null
		else:
			switch_options.text = "No plugin selected"
			switch_options.icon = null

# Currently not implemented anywhere,
# It is useful, for writing plugins
# which have main screens, to keep the same
# tab selected across reloads.
# The main screen tab tends to change
# because the plugin's tab ceases to exist
# when it is deactivated.
func get_main_screen()->String:
	var screen:String
	var base:Panel = refresh_plugin.get_editor_interface().get_base_control()
	var editor_head:BoxContainer = base.get_child(0).get_child(0)
	if editor_head.get_child_count()<3:
		# may happen when calling from plugin _init()
		return screen
	var main_screen_buttons:Array = editor_head.get_child(2).get_children()
	for button in main_screen_buttons:
		if button.pressed:
			screen = button.text
			break
	return screen
