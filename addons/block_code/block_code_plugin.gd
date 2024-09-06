@tool
extends EditorPlugin
const MainPanelScene := preload("res://addons/block_code/ui/main_panel.tscn")
const MainPanel = preload("res://addons/block_code/ui/main_panel.gd")
const Types = preload("res://addons/block_code/types/types.gd")
const ScriptWindow := preload("res://addons/block_code/ui/script_window/script_window.tscn")

static var main_panel: MainPanel
static var block_code_button: Button

const BlockInspectorPlugin := preload("res://addons/block_code/inspector_plugin/block_script_inspector.gd")
var block_inspector_plugin: BlockInspectorPlugin

var editor_inspector: EditorInspector
var editor_selection: EditorSelection

var _selected_block_code: BlockCode

var old_feature_profile: String = ""

const DISABLED_CLASSES := [
	"Block",
	"ControlBlock",
	"ParameterBlock",
	"StatementBlock",
	"SnapPoint",
	"BlockScriptSerialization",
	"CategoryFactory",
]


func _enter_tree():
	Types.init_cast_graph()

	editor_inspector = EditorInterface.get_inspector()
	editor_selection = EditorInterface.get_selection()

	main_panel = MainPanelScene.instantiate()
	main_panel.script_window_requested.connect(script_window_requested)
	main_panel.undo_redo = get_undo_redo()
	block_code_button = add_control_to_bottom_panel(main_panel, _get_plugin_name())
	block_inspector_plugin = BlockInspectorPlugin.new()
	add_inspector_plugin(block_inspector_plugin)

	# Remove unwanted class nodes from create node
	old_feature_profile = EditorInterface.get_current_feature_profile()

	var editor_paths: EditorPaths = EditorInterface.get_editor_paths()
	if editor_paths:
		var config_dir := editor_paths.get_config_dir()
		var new_profile := EditorFeatureProfile.new()
		new_profile.load_from_file(config_dir + "/feature_profiles/" + old_feature_profile + ".profile")
		for _class_name in DISABLED_CLASSES:
			new_profile.set_disable_class(_class_name, true)

		var dir = config_dir + "/feature_profiles/block_code.profile"
		DirAccess.remove_absolute(dir)
		new_profile.save_to_file(dir)
		EditorInterface.set_current_feature_profile("block_code")


func script_window_requested(script: String):
	var script_window = ScriptWindow.instantiate()
	script_window.script_content = script

	EditorInterface.get_base_control().add_child(script_window)

	await script_window.close_requested

	script_window.queue_free()
	script_window = null


func _exit_tree():
	remove_inspector_plugin(block_inspector_plugin)

	if block_code_button:
		remove_control_from_bottom_panel(main_panel)
		block_code_button = null

	if main_panel:
		main_panel.queue_free()
		main_panel = null

	var editor_paths: EditorPaths = EditorInterface.get_editor_paths()
	if editor_paths:
		var config_dir := editor_paths.get_config_dir()
		if old_feature_profile == "" or FileAccess.file_exists(config_dir + "/feature_profiles/" + old_feature_profile + ".profile"):
			EditorInterface.set_current_feature_profile(old_feature_profile)
		else:
			print("Old feature profile was removed and cannot be reverted to. Reverting to default.")
			EditorInterface.set_current_feature_profile("")


func _ready():
	connect("scene_changed", _on_scene_changed)
	editor_inspector.connect("edited_object_changed", _on_editor_inspector_edited_object_changed)
	_on_scene_changed(EditorInterface.get_edited_scene_root())
	_on_editor_inspector_edited_object_changed()


func _on_scene_changed(scene_root: Node):
	main_panel.switch_scene(scene_root)


func _on_editor_inspector_edited_object_changed():
	var edited_object = editor_inspector.get_edited_object()
	#var edited_node = edited_object as Node
	var selected_nodes = editor_selection.get_selected_nodes()

	if edited_object is BlockCode:
		make_bottom_panel_item_visible(main_panel)

	if edited_object is BlockCode and selected_nodes.size() == 1 and edited_object.owner and edited_object != _selected_block_code:
		# If a BlockCode node is being edited, and it was explicitly selected
		# (as opposed to edited in the Inspector alone), select its parent node
		# as well. This provides a clearer indication of what is being edited.
		# Changing the selection will cause edited_object_changed to fire again,
		# so we will return early to avoid duplicate work.
		var parent_node = edited_object.get_parent()
		if parent_node:
			editor_selection.add_node.call_deferred(parent_node)
		return

	if edited_object and edited_object.get_class() == "MultiNodeEdit":
		# If multiple nodes are shown in the inspector, we will find the first
		# BlockCode node in the list of selected nodes and use that. This
		# occurs when the user selects multiple items in the Scene panel, or
		# when we select the parent of a BlockCode node.
		edited_object = selected_nodes.filter(func(node): return node is BlockCode).pop_front()

	var block_code_node = list_block_code_nodes_for_node(edited_object as Node).pop_front()
	select_block_code_node(block_code_node)


func select_block_code_node(block_code: BlockCode):
	# Skip duplicate selection unless new node is null. That happens when any
	# non-BlockCode node is selected and that needs to be passed through to the
	# main panel.
	if block_code and block_code == _selected_block_code:
		return

	if not is_block_code_editable(block_code):
		block_code = null

	if is_instance_valid(_selected_block_code):
		_selected_block_code.tree_entered.disconnect(_on_selected_block_code_changed)
		_selected_block_code.tree_exited.disconnect(_on_selected_block_code_changed)
		_selected_block_code.property_list_changed.disconnect(_on_selected_block_code_changed)
		editor_inspector.property_edited.disconnect(_on_editor_inspector_property_edited)

	_selected_block_code = block_code

	if is_instance_valid(_selected_block_code):
		_selected_block_code.tree_entered.connect(_on_selected_block_code_changed)
		_selected_block_code.tree_exited.connect(_on_selected_block_code_changed)
		_selected_block_code.property_list_changed.connect(_on_selected_block_code_changed)
		editor_inspector.property_edited.connect(_on_editor_inspector_property_edited)

	_refresh_block_code_node()


func _refresh_block_code_node():
	if main_panel:
		main_panel.switch_block_code_node(_selected_block_code)


func _on_selected_block_code_changed():
	if _selected_block_code:
		_refresh_block_code_node()


func _on_editor_inspector_property_edited(property: String):
	if _selected_block_code:
		_refresh_block_code_node()


static func is_block_code_editable(block_code: BlockCode) -> bool:
	if not block_code:
		return false

	# A BlockCode node can be edited if it belongs to the edited scene, or it
	# is an editable instance.

	var scene_node = EditorInterface.get_edited_scene_root()

	return block_code == scene_node or block_code.owner == scene_node or scene_node.is_editable_instance(block_code.owner)


static func node_has_block_code(node: Node, recursive: bool = false) -> bool:
	return list_block_code_nodes_for_node(node, recursive).size() > 0


static func list_block_code_nodes_for_node(node: Node, recursive: bool = false) -> Array[BlockCode]:
	var result: Array[BlockCode] = []

	if node is BlockCode:
		result.append(node)
	elif node:
		result.append_array(node.find_children("*", "BlockCode", recursive))

	return result


func _get_plugin_name():
	return "Block Code"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
