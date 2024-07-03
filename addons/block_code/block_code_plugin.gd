@tool
class_name BlockCodePlugin
extends EditorPlugin

const MainPanel := preload("res://addons/block_code/ui/main_panel.tscn")
static var main_panel

var editor_inspector: EditorInspector

var old_feature_profile: String = ""

const DISABLED_CLASSES := [
	"BlockScriptData",
	"DragManager",
	"InstructionTree",
	"Types",
	"Block",
	"ControlBlock",
	"ParameterBlock",
	"StatementBlock",
	"DragDropArea",
	"SnapPoint",
	"NodeBlockCanvas",
	"SerializedBlockTreeNodeArray",
	"SerializedBlockTreeNode",
	"SerializedBlock",
	"PackedSceneTreeNodeArray",
	"PackedSceneTreeNode",
	"BlockCanvas",
	"NodeCanvas",
	"NodeClass",
	"NodeClassList",
	"NodeData",
	"NodePreview",
	"NodeList",
	"CategoryFactory",
	"BlockCategoryDisplay",
	"BlockCategory",
	"Picker",
	"TitleBar",
	"MainPanel",
	"BlockCodePlugin",
	"BlockCategoryButton"
]


func _enter_tree():
	Types.init_cast_graph()

	editor_inspector = EditorInterface.get_inspector()

	main_panel = MainPanel.instantiate()
	main_panel.undo_redo = get_undo_redo()

	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(main_panel)
	# Hide the main panel. Very much required.
	_make_visible(false)

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


func _exit_tree():
	if main_panel:
		main_panel.queue_free()

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
	BlockCodePlugin.main_panel.switch_scene(scene_root)


func _on_editor_inspector_edited_object_changed():
	var block_code: BlockCode = editor_inspector.get_edited_object() as BlockCode
	BlockCodePlugin.main_panel.switch_script(block_code)


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel:
		main_panel.visible = visible


func _get_plugin_name():
	return "Block Code"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
