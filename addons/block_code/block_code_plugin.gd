@tool
class_name BlockCodePlugin
extends EditorPlugin

const MainPanel := preload("res://addons/block_code/ui/main_panel.tscn")
static var main_panel: MainPanel
static var block_code_button: Button

var editor_inspector: EditorInspector

var selected_block_code_node: BlockCode

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
	block_code_button = add_control_to_bottom_panel(main_panel, _get_plugin_name())

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
	editor_inspector.connect("property_edited", _on_editor_inspector_property_edited)
	_on_scene_changed(EditorInterface.get_edited_scene_root())
	_on_editor_inspector_edited_object_changed()


func _on_scene_changed(scene_root: Node):
	BlockCodePlugin.main_panel.switch_scene(scene_root)
	_on_editor_inspector_edited_object_changed()


func _on_editor_inspector_edited_object_changed():
	var edited_node = editor_inspector.get_edited_object() as Node

	# We will edit either the selected node (if it is a BlockCode node) or
	# the first BlockCode child of that node.
	selected_block_code_node = list_block_code_for_node(edited_node).pop_front()
	if not is_block_code_editable(selected_block_code_node):
		selected_block_code_node = null

	BlockCodePlugin.main_panel.switch_block_code_node(selected_block_code_node)
	if edited_node is BlockCode:
		# If the user explicitly chose a BlockCode node, show the Block Code
		# editor. We only do this for the BlockCode node itself, rather than
		# nodes containing BlockCode, to avoid conflicts with other panels.
		make_bottom_panel_item_visible(main_panel)


static func is_block_code_editable(block_code: BlockCode) -> bool:
	if not block_code:
		return false

	# A BlockCode node can be edited if it belongs to the edited scene, or it
	# is an editable instance.

	var scene_node = EditorInterface.get_edited_scene_root()

	return block_code == scene_node or block_code.owner == scene_node or scene_node.is_editable_instance(block_code.owner)


static func node_has_block_code(node: Node, recursive: bool = false) -> bool:
	return list_block_code_for_node(node, recursive).size() > 0


static func list_block_code_for_node(node: Node, recursive: bool = false) -> Array[BlockCode]:
	var result: Array[BlockCode] = []

	if node is BlockCode:
		result.append(node)
	elif node:
		result.append_array(node.find_children("*", "BlockCode", recursive))

	return result


func _on_editor_inspector_property_edited(property: String):
	if selected_block_code_node:
		_on_editor_inspector_edited_object_changed()


func _get_plugin_name():
	return "Block Code"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
