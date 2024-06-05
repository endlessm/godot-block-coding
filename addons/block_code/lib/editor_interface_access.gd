class_name EditorInterfaceAccess
extends Object

## Finds and gives easy access to many key Control nodes of the Godot editor.
## Extend this script to add support for more areas of the Godot editor or Godot plugins.
const Utils := preload("utils.gd")

## This is the base control of the Godot editor, the parent to all UI nodes in the entire
## application.
var base_control: Control = null

# Title Bar
var menu_bar: MenuBar = null
## The "main screen" buttons centered at the top of the editor (2D, 3D, Script, and AssetLib).
var context_switcher: HBoxContainer = null
var context_switcher_2d_button: Button = null
var context_switcher_3d_button: Button = null
var context_switcher_script_button: Button = null
var context_switcher_asset_lib_button: Button = null
var run_bar: MarginContainer = null
var run_bar_play_button: Button = null
var run_bar_pause_button: Button = null
var run_bar_stop_button: Button = null
var run_bar_debug_button: MenuButton = null
var run_bar_play_current_button: Button = null
var run_bar_play_custom_button: Button = null
var run_bar_movie_mode_button: Button = null
var rendering_options: OptionButton = null

# Main Screen
var main_screen: VBoxContainer = null
var main_screen_tabs: TabBar = null
var distraction_free_button: Button = null

var canvas_item_editor: VBoxContainer = null
## The 2D viewport in the 2D editor. Its bounds stop right before the toolbar.
var canvas_item_editor_viewport: Control = null
var canvas_item_editor_toolbar: Control = null
var canvas_item_editor_toolbar_select_button: Button = null
var canvas_item_editor_toolbar_move_button: Button = null
var canvas_item_editor_toolbar_rotate_button: Button = null
var canvas_item_editor_toolbar_scale_button: Button = null
var canvas_item_editor_toolbar_selectable_button: Button = null
var canvas_item_editor_toolbar_pivot_button: Button = null
var canvas_item_editor_toolbar_pan_button: Button = null
var canvas_item_editor_toolbar_ruler_button: Button = null
var canvas_item_editor_toolbar_smart_snap_button: Button = null
var canvas_item_editor_toolbar_grid_button: Button = null
var canvas_item_editor_toolbar_snap_options_button: MenuButton = null
var canvas_item_editor_toolbar_lock_button: Button = null
var canvas_item_editor_toolbar_unlock_button: Button = null
var canvas_item_editor_toolbar_group_button: Button = null
var canvas_item_editor_toolbar_ungroup_button: Button = null
var canvas_item_editor_toolbar_skeleton_options_button: Button = null
## Parent container of the zoom buttons in the top-left of the 2D editor.
var canvas_item_editor_zoom_widget: Control = null
## Lower zoom button in the top-left of the 2D viewport.
var canvas_item_editor_zoom_button_lower: Button = null
## Button showing the current zoom percentage in the top-left of the 2D viewport. Pressing it resets
## the zoom to 100%.
var canvas_item_editor_zoom_button_reset: Button = null
## Increase zoom button in the top-left of the 2D viewport.
var canvas_item_editor_zoom_button_increase: Button = null

var spatial_editor: Control = null
var spatial_editor_surfaces: Array[Control] = []
var spatial_editor_surfaces_menu_buttons: Array[MenuButton] = []
var spatial_editor_viewports: Array[Control] = []
var spatial_editor_preview_check_boxes: Array[CheckBox] = []
var spatial_editor_cameras: Array[Camera3D] = []
var spatial_editor_toolbar: Control = null
var spatial_editor_toolbar_select_button: Button = null
var spatial_editor_toolbar_move_button: Button = null
var spatial_editor_toolbar_rotate_button: Button = null
var spatial_editor_toolbar_scale_button: Button = null
var spatial_editor_toolbar_selectable_button: Button = null
var spatial_editor_toolbar_lock_button: Button = null
var spatial_editor_toolbar_unlock_button: Button = null
var spatial_editor_toolbar_group_button: Button = null
var spatial_editor_toolbar_ungroup_button: Button = null
var spatial_editor_toolbar_local_button: Button = null
var spatial_editor_toolbar_snap_button: Button = null
var spatial_editor_toolbar_camera_button: Button = null
var spatial_editor_toolbar_sun_button: Button = null
var spatial_editor_toolbar_environment_button: Button = null
var spatial_editor_toolbar_sun_environment_button: Button = null
var spatial_editor_toolbar_transform_menu_button: MenuButton = null
var spatial_editor_toolbar_view_menu_button: MenuButton = null

var script_editor: ScriptEditor = null
## Parent node of the script editor, used to pop out the editor and controls the script editor's
## visibility. Used to check if students are in the scripting context.
var script_editor_window_wrapper: Node = null
var script_editor_top_bar: HBoxContainer = null
var script_editor_items: ItemList = null
var script_editor_items_panel: VBoxContainer = null
var script_editor_functions_panel: VBoxContainer = null
var script_editor_code_panel: VBoxContainer = null
var asset_lib: PanelContainer = null

# Snap Dialog, AKA Configure Snap window
var snap_options_window: ConfirmationDialog = null
var snap_options_cancel_button: Button = null
var snap_options_ok_button: Button = null
var snap_options: VBoxContainer = null
var snap_options_grid_offset_controls: Array[Control] = []
var snap_options_grid_step_controls: Array[Control] = []
var snap_options_primary_line_controls: Array[Control] = []
var snap_options_rotation_offset_controls: Array[Control] = []
var snap_options_rotation_step_controls: Array[Control] = []
var snap_options_scale_step_controls: Array[Control] = []

# Left Upper
var scene_tabs: TabBar = null
var scene_dock: VBoxContainer = null
var scene_dock_button_add: Button = null
var scene_tree: Tree = null
var import_dock: VBoxContainer = null
var select_node_window: ConfirmationDialog = null

var node_create_window: ConfirmationDialog = null
var script_create_window: ConfirmationDialog = null
var node_create_panel: HSplitContainer = null
var node_create_dialog_node_tree: Tree = null
var node_create_dialog_search_bar: LineEdit = null
var node_create_dialog_button_create: Button = null
var node_create_dialog_button_cancel: Button = null

# Left Bttom
var filesystem_tabs: TabBar = null
var filesystem_dock: VBoxContainer = null
var filesystem_tree: Tree = null

# Right
var inspector_tabs: TabBar = null
var inspector_dock: VBoxContainer = null
var inspector_editor: EditorInspector = null

var node_dock: VBoxContainer = null
var node_dock_buttons_box: HBoxContainer = null
var node_dock_signals_button: Button = null
var node_dock_groups_button: Button = null
var node_dock_signals_editor: VBoxContainer = null
var node_dock_signals_tree: Tree = null

var signals_dialog_window: ConfirmationDialog = null
var signals_dialog: HBoxContainer = null
var signals_dialog_tree: Tree = null
var signals_dialog_signal_line_edit: LineEdit = null
var signals_dialog_method_line_edit: LineEdit = null
var signals_dialog_cancel_button: Button = null
var signals_dialog_ok_button: Button = null
var node_dock_groups_editor: VBoxContainer = null
var history_dock: VBoxContainer = null

# Bottom
var bottom_panels_container: Control = null

var tilemap: Control = null
var tilemap_tabs: TabBar = null
var tilemap_tiles_panel: VBoxContainer = null
var tilemap_tiles: ItemList = null
var tilemap_tiles_atlas_view: Control = null
var tilemap_tiles_toolbar: HBoxContainer = null
var tilemap_patterns_panel: VBoxContainer = null
var tilemap_terrains_panel: VBoxContainer = null
## The tree on the left to select terrains in the TileMap -> Terrains tab.
var tilemap_terrains_tree: Tree = null
## The list of terrain drawing mode and individual tiles on the right in the TileMap -> Terrains tab.
var tilemap_terrains_tiles: ItemList = null
var tilemap_terrains_toolbar: HBoxContainer = null
var tilemap_terrains_tool_draw: Button = null
var tilemap_panels: Array[Control] = []

var tileset: Control = null
var tileset_tabs: TabBar = null
var tileset_tiles_panel: HSplitContainer = null
var tileset_patterns_panel: ItemList = null
var tileset_panels: Array[Control] = []

var logger: HBoxContainer = null
var logger_rich_text_label: RichTextLabel = null
var debugger: MarginContainer = null
var find_in_files: Control = null
var audio_buses: VBoxContainer = null
var animation_player: VBoxContainer = null
var shader: MarginContainer = null

var bottom_buttons_container: HBoxContainer = null
var bottom_button_output: Button = null
var bottom_button_debugger: Button = null
var bottom_button_tilemap: Button = null
var bottom_button_tileset: Button = null
var bottom_buttons: Array[Button] = []

var scene_import_settings_window: ConfirmationDialog = null
var scene_import_settings: VBoxContainer = null
var scene_import_settings_ok_button: Button = null
var scene_import_settings_cancel_button: Button = null

var windows: Array[ConfirmationDialog] = []


func _init() -> void:
	base_control = EditorInterface.get_base_control()

	# Top
	var editor_title_bar := Utils.find_child_by_type(base_control, "EditorTitleBar")
	menu_bar = Utils.find_child_by_type(editor_title_bar, "MenuBar")

	context_switcher = Utils.find_child_by_type(
		editor_title_bar,
		"HBoxContainer",
		true,
		func(c: HBoxContainer) -> bool: return c.get_child_count() > 1
	)
	var context_switcher_buttons := context_switcher.get_children()
	context_switcher_2d_button = context_switcher_buttons[0]
	context_switcher_3d_button = context_switcher_buttons[1]
	context_switcher_script_button = context_switcher_buttons[2]
	context_switcher_asset_lib_button = context_switcher_buttons[3]

	run_bar = Utils.find_child_by_type(editor_title_bar, "EditorRunBar")
	var run_bar_buttons = run_bar.find_children("", "Button", true, false)
	run_bar_play_button = run_bar_buttons[0]
	run_bar_pause_button = run_bar_buttons[1]
	run_bar_stop_button = run_bar_buttons[2]
	run_bar_debug_button = run_bar_buttons[3]
	run_bar_play_current_button = run_bar_buttons[5]
	run_bar_play_custom_button = run_bar_buttons[6]
	run_bar_movie_mode_button = run_bar_buttons[7]
	rendering_options = Utils.find_child_by_type(editor_title_bar, "OptionButton")

	# Main Screen
	main_screen = EditorInterface.get_editor_main_screen()
	main_screen_tabs = Utils.find_child_by_type(main_screen.get_parent().get_parent(), "TabBar")
	distraction_free_button = (
		main_screen_tabs.get_parent().find_children("", "Button", true, false).back()
	)
	canvas_item_editor = Utils.find_child_by_type(main_screen, "CanvasItemEditor")
	canvas_item_editor_viewport = Utils.find_child_by_type(
		canvas_item_editor, "CanvasItemEditorViewport"
	)
	canvas_item_editor_toolbar = canvas_item_editor.get_child(0).get_child(0).get_child(0)
	var canvas_item_editor_toolbar_buttons := canvas_item_editor_toolbar.find_children(
		"", "Button", false, false
	)
	canvas_item_editor_toolbar_select_button = canvas_item_editor_toolbar_buttons[0]
	canvas_item_editor_toolbar_move_button = canvas_item_editor_toolbar_buttons[1]
	canvas_item_editor_toolbar_rotate_button = canvas_item_editor_toolbar_buttons[2]
	canvas_item_editor_toolbar_scale_button = canvas_item_editor_toolbar_buttons[3]
	canvas_item_editor_toolbar_selectable_button = canvas_item_editor_toolbar_buttons[4]
	canvas_item_editor_toolbar_pivot_button = canvas_item_editor_toolbar_buttons[5]
	canvas_item_editor_toolbar_pan_button = canvas_item_editor_toolbar_buttons[6]
	canvas_item_editor_toolbar_ruler_button = canvas_item_editor_toolbar_buttons[7]
	canvas_item_editor_toolbar_smart_snap_button = canvas_item_editor_toolbar_buttons[8]
	canvas_item_editor_toolbar_grid_button = canvas_item_editor_toolbar_buttons[9]
	canvas_item_editor_toolbar_snap_options_button = canvas_item_editor_toolbar_buttons[10]
	canvas_item_editor_toolbar_lock_button = canvas_item_editor_toolbar_buttons[11]
	canvas_item_editor_toolbar_unlock_button = canvas_item_editor_toolbar_buttons[12]
	canvas_item_editor_toolbar_group_button = canvas_item_editor_toolbar_buttons[13]
	canvas_item_editor_toolbar_ungroup_button = canvas_item_editor_toolbar_buttons[14]
	canvas_item_editor_toolbar_skeleton_options_button = canvas_item_editor_toolbar_buttons[15]

	canvas_item_editor_zoom_widget = Utils.find_child_by_type(
		canvas_item_editor, "EditorZoomWidget"
	)
	canvas_item_editor_zoom_button_lower = canvas_item_editor_zoom_widget.get_child(0)
	canvas_item_editor_zoom_button_reset = canvas_item_editor_zoom_widget.get_child(1)
	canvas_item_editor_zoom_button_increase = canvas_item_editor_zoom_widget.get_child(2)

	snap_options_window = Utils.find_child_by_type(base_control, "SnapDialog")
	snap_options = snap_options_window.get_child(0)
	snap_options_cancel_button = snap_options_window.get_cancel_button()
	snap_options_ok_button = snap_options_window.get_ok_button()
	var snap_options_controls: Array[Node] = snap_options.get_child(0).get_children()
	snap_options_grid_offset_controls.assign(snap_options_controls.slice(0, 3))
	snap_options_grid_step_controls.assign(snap_options_controls.slice(3, 6))
	snap_options_primary_line_controls.assign(snap_options_controls.slice(6, 9))
	snap_options_controls = snap_options.get_child(2).get_children()
	snap_options_rotation_offset_controls.assign(snap_options_controls.slice(0, 2))
	snap_options_rotation_step_controls.assign(snap_options_controls.slice(2, 4))
	snap_options_scale_step_controls.assign(snap_options.get_child(4).get_children())

	spatial_editor = Utils.find_child_by_type(main_screen, "Node3DEditor")
	spatial_editor_viewports.assign(
		spatial_editor.find_children("", "Node3DEditorViewport", true, false)
	)
	spatial_editor_preview_check_boxes.assign(
		spatial_editor.find_children("", "CheckBox", true, false)
	)
	spatial_editor_cameras.assign(spatial_editor.find_children("", "Camera3D", true, false))
	var surfaces := {}
	for surface in spatial_editor.find_children("", "ViewportNavigationControl", true, false).map(
		func(c: Control) -> Control: return c.get_parent()
	):
		surfaces[surface] = null
	spatial_editor_surfaces.assign(surfaces.keys())
	for surface in spatial_editor_surfaces:
		spatial_editor_surfaces_menu_buttons.append_array(
			surface.find_children("", "MenuButton", true, false)
		)
	spatial_editor_toolbar = spatial_editor.get_child(0).get_child(0).get_child(0)
	var spatial_editor_toolbar_buttons := spatial_editor_toolbar.find_children(
		"", "Button", false, false
	)
	spatial_editor_toolbar_select_button = spatial_editor_toolbar_buttons[0]
	spatial_editor_toolbar_move_button = spatial_editor_toolbar_buttons[1]
	spatial_editor_toolbar_rotate_button = spatial_editor_toolbar_buttons[2]
	spatial_editor_toolbar_scale_button = spatial_editor_toolbar_buttons[3]
	spatial_editor_toolbar_selectable_button = spatial_editor_toolbar_buttons[4]
	spatial_editor_toolbar_lock_button = spatial_editor_toolbar_buttons[5]
	spatial_editor_toolbar_unlock_button = spatial_editor_toolbar_buttons[6]
	spatial_editor_toolbar_group_button = spatial_editor_toolbar_buttons[7]
	spatial_editor_toolbar_ungroup_button = spatial_editor_toolbar_buttons[8]
	spatial_editor_toolbar_local_button = spatial_editor_toolbar_buttons[9]
	spatial_editor_toolbar_snap_button = spatial_editor_toolbar_buttons[10]
	spatial_editor_toolbar_camera_button = spatial_editor_toolbar_buttons[11]
	spatial_editor_toolbar_sun_button = spatial_editor_toolbar_buttons[12]
	spatial_editor_toolbar_environment_button = spatial_editor_toolbar_buttons[13]
	spatial_editor_toolbar_sun_environment_button = spatial_editor_toolbar_buttons[14]
	spatial_editor_toolbar_transform_menu_button = spatial_editor_toolbar_buttons[15]
	spatial_editor_toolbar_view_menu_button = spatial_editor_toolbar_buttons[16]

	script_editor = EditorInterface.get_script_editor()
	script_editor_window_wrapper = script_editor.get_parent()
	script_editor_code_panel = script_editor.get_child(0).get_child(1).get_child(1)
	script_editor_top_bar = script_editor.get_child(0).get_child(0)
	script_editor_items = Utils.find_child_by_type(script_editor, "ItemList")
	script_editor_items_panel = script_editor_items.get_parent()
	script_editor_functions_panel = script_editor_items_panel.get_parent().get_child(1)
	asset_lib = Utils.find_child_by_type(main_screen, "EditorAssetLibrary")

	# Left Upper
	scene_dock = Utils.find_child_by_type(base_control, "SceneTreeDock")
	scene_dock_button_add = scene_dock.get_child(0).get_child(0)
	node_create_window = Utils.find_child_by_type(scene_dock, "CreateDialog")
	script_create_window = Utils.find_child_by_type(scene_dock, "ScriptCreateDialog")
	node_create_panel = Utils.find_child_by_type(node_create_window, "HSplitContainer")
	var node_create_dialog_vboxcontainer: VBoxContainer = Utils.find_child_by_type(
		node_create_panel, "VBoxContainer", false
	)
	node_create_dialog_node_tree = Utils.find_child_by_type(
		node_create_dialog_vboxcontainer, "Tree"
	)
	node_create_dialog_search_bar = Utils.find_child_by_type(
		node_create_dialog_vboxcontainer, "LineEdit"
	)
	node_create_dialog_button_create = node_create_window.get_ok_button()
	node_create_dialog_button_cancel = node_create_window.get_cancel_button()
	scene_tabs = Utils.find_child_by_type(scene_dock.get_parent(), "TabBar")
	var scene_tree_editor := Utils.find_child_by_type(scene_dock, "SceneTreeEditor")
	scene_tree = Utils.find_child_by_type(scene_tree_editor, "Tree")
	select_node_window = Utils.find_child_by_type(base_control, "SceneTreeDialog")
	import_dock = Utils.find_child_by_type(base_control, "ImportDock")

	# Left Bottom
	filesystem_dock = Utils.find_child_by_type(base_control, "FileSystemDock")
	filesystem_tabs = Utils.find_child_by_type(filesystem_dock.get_parent(), "TabBar")
	filesystem_tree = Utils.find_child_by_type(
		Utils.find_child_by_type(filesystem_dock, "SplitContainer"), "Tree"
	)

	# Right
	inspector_dock = Utils.find_child_by_type(base_control, "InspectorDock")
	inspector_tabs = Utils.find_child_by_type(inspector_dock.get_parent(), "TabBar")
	inspector_editor = EditorInterface.get_inspector()
	node_dock = Utils.find_child_by_type(base_control, "NodeDock")
	node_dock_buttons_box = node_dock.get_child(0)
	var node_dock_buttons := node_dock_buttons_box.get_children()
	node_dock_signals_button = node_dock_buttons[0]
	node_dock_groups_button = node_dock_buttons[1]
	node_dock_signals_editor = Utils.find_child_by_type(node_dock, "ConnectionsDock")
	node_dock_signals_tree = Utils.find_child_by_type(node_dock_signals_editor, "Tree")

	signals_dialog_window = Utils.find_child_by_type(node_dock_signals_editor, "ConnectDialog")
	signals_dialog = signals_dialog_window.get_child(0)
	signals_dialog_tree = Utils.find_child_by_type(signals_dialog, "Tree")
	var signals_dialog_line_edits := signals_dialog.get_child(0).find_children(
		"", "LineEdit", true, false
	)
	signals_dialog_signal_line_edit = signals_dialog_line_edits[0]
	signals_dialog_method_line_edit = signals_dialog_line_edits[-1]
	signals_dialog_cancel_button = signals_dialog_window.get_cancel_button()
	signals_dialog_ok_button = signals_dialog_window.get_ok_button()
	node_dock_groups_editor = Utils.find_child_by_type(node_dock, "GroupsEditor")
	history_dock = Utils.find_child_by_type(base_control, "HistoryDock")

	# Bottom
	logger = Utils.find_child_by_type(base_control, "EditorLog")
	logger_rich_text_label = Utils.find_child_by_type(logger, "RichTextLabel")

	bottom_panels_container = logger.get_parent().get_parent()
	var bottom_panels_vboxcontainer: VBoxContainer = logger.get_parent()

	debugger = Utils.find_child_by_type(bottom_panels_vboxcontainer, "EditorDebuggerNode", false)
	find_in_files = Utils.find_child_by_type(bottom_panels_vboxcontainer, "FindInFilesPanel", false)
	audio_buses = Utils.find_child_by_type(bottom_panels_vboxcontainer, "EditorAudioBuses", false)
	animation_player = Utils.find_child_by_type(
		bottom_panels_vboxcontainer, "AnimationPlayerEditor", false
	)
	shader = Utils.find_child_by_type(bottom_panels_vboxcontainer, "WindowWrapper", false)
	var editor_toaster := Utils.find_child_by_type(bottom_panels_vboxcontainer, "EditorToaster")
	bottom_buttons_container = Utils.find_child_by_type(
		editor_toaster.get_parent(), "HBoxContainer", false
	)

	var bottom_button_children := bottom_buttons_container.get_children()
	bottom_button_output = bottom_button_children[0]
	bottom_button_debugger = bottom_button_children[1]
	bottom_button_tileset = bottom_button_children[-3]
	bottom_button_tilemap = bottom_button_children[-2]
	bottom_buttons = [
		bottom_button_output, bottom_button_debugger, bottom_button_tileset, bottom_button_tilemap
	]

	tilemap = Utils.find_child_by_type(bottom_panels_vboxcontainer, "TileMapEditor", false)
	var tilemap_flow_container: HFlowContainer = Utils.find_child_by_type(
		tilemap, "HFlowContainer", false
	)
	tilemap_tabs = tilemap_flow_container.get_child(0)

	tilemap_tiles_panel = tilemap.get_child(2)
	var tilemap_tiles_hsplitcontainer: HSplitContainer = Utils.find_child_by_type(
		tilemap_tiles_panel, "HSplitContainer", false
	)
	tilemap_tiles = Utils.find_child_by_type(tilemap_tiles_hsplitcontainer, "ItemList")
	tilemap_tiles_atlas_view = Utils.find_child_by_type(
		tilemap_tiles_hsplitcontainer, "TileAtlasView", false
	)
	tilemap_tiles_toolbar = tilemap_flow_container.get_child(1)

	tilemap_patterns_panel = tilemap.get_child(3)
	tilemap_terrains_panel = tilemap.get_child(4)
	var tilemap_terrains_hsplitcontainer: HSplitContainer = tilemap_terrains_panel.get_child(0)
	tilemap_terrains_tree = Utils.find_child_by_type(tilemap_terrains_hsplitcontainer, "Tree")
	tilemap_terrains_tiles = Utils.find_child_by_type(tilemap_terrains_hsplitcontainer, "ItemList")
	tilemap_terrains_toolbar = tilemap_flow_container.get_child(2)
	tilemap_terrains_tool_draw = tilemap_terrains_toolbar.get_child(0).get_child(0)

	tilemap_panels = [tilemap_tiles_panel, tilemap_patterns_panel, tilemap_terrains_panel]

	tileset = Utils.find_child_by_type(bottom_panels_vboxcontainer, "TileSetEditor", false)
	tileset_tabs = Utils.find_child_by_type(tileset, "TabBar")
	tileset_tiles_panel = tileset.get_child(0).get_child(1)
	tileset_patterns_panel = tileset.get_child(0).get_child(2)
	tileset_panels = [tileset_tiles_panel, tileset_patterns_panel]

	scene_import_settings_window = Utils.find_child_by_type(base_control, "SceneImportSettings")
	scene_import_settings = scene_import_settings_window.get_child(0)
	scene_import_settings_cancel_button = scene_import_settings_window.get_cancel_button()
	scene_import_settings_ok_button = scene_import_settings_window.get_ok_button()

	windows.assign([signals_dialog_window, node_create_window, scene_import_settings_window])
	for window in windows:
		window_toggle_tour_mode(window, true)


func clean_up() -> void:
	for window in windows:
		window_toggle_tour_mode(window, false)


func window_toggle_tour_mode(window: ConfirmationDialog, is_in_tour: bool) -> void:
	window.dialog_close_on_escape = not is_in_tour
	window.transient = is_in_tour
	window.exclusive = not is_in_tour
	window.physics_object_picking = is_in_tour
	window.physics_object_picking_sort = is_in_tour


## Applies the Default layout to the editor.
## This is the equivalent of going to Editor -> Editor Layout -> Default.
##
## We call this at the start of a tour, so that every tour starts from the same base layout.
## This can't be done in the _init() function because upon opening Godot, loading previously opened
## scenes and restoring the user's editor layout can take several seconds.
func restore_default_layout() -> void:
	var editor_popup_menu := menu_bar.get_menu_popup(3)
	for layouts_popup_menu: PopupMenu in editor_popup_menu.get_children():
		var id: int = layouts_popup_menu.get_item_id(3)
		layouts_popup_menu.id_pressed.emit(id)


func unfold_tree_item(item: TreeItem) -> void:
	var parent := item.get_parent()
	if parent != null:
		item = parent

	var tree := item.get_tree()
	while item != tree.get_root():
		item.collapsed = false
		item = item.get_parent()


func is_in_scripting_context() -> bool:
	return script_editor_window_wrapper.visible
