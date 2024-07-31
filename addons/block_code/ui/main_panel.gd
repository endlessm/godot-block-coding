@tool
extends Control

signal script_window_requested(script: String)

const BlockCanvas = preload("res://addons/block_code/ui/block_canvas/block_canvas.gd")
const BlockCodePlugin = preload("res://addons/block_code/block_code_plugin.gd")
const DragManager = preload("res://addons/block_code/drag_manager/drag_manager.gd")
const Picker = preload("res://addons/block_code/ui/picker/picker.gd")
const TitleBar = preload("res://addons/block_code/ui/title_bar/title_bar.gd")

@onready var _picker: Picker = %Picker
@onready var _block_canvas: BlockCanvas = %BlockCanvas
@onready var _drag_manager: DragManager = %DragManager
@onready var _title_bar: TitleBar = %TitleBar
@onready var _delete_node_button: Button = %DeleteNodeButton
@onready var _editor_inspector: EditorInspector = EditorInterface.get_inspector()
@onready var _picker_split: HSplitContainer = %PickerSplit
@onready var _collapse_button: Button = %CollapseButton

@onready var _icon_delete := EditorInterface.get_editor_theme().get_icon("Remove", "EditorIcons")
@onready var _icon_collapse := EditorInterface.get_editor_theme().get_icon("Back", "EditorIcons")
@onready var _icon_expand := EditorInterface.get_editor_theme().get_icon("Forward", "EditorIcons")

const Constants = preload("res://addons/block_code/ui/constants.gd")

var _current_block_code_node: BlockCode
var _block_code_nodes: Array
var _collapsed: bool = false

var undo_redo: EditorUndoRedoManager:
	set(value):
		if undo_redo:
			undo_redo.version_changed.disconnect(_on_undo_redo_version_changed)
		undo_redo = value
		if undo_redo:
			undo_redo.version_changed.connect(_on_undo_redo_version_changed)


func _ready():
	_picker.block_picked.connect(_drag_manager.copy_picked_block_and_drag)
	_picker.variable_created.connect(_create_variable)
	_block_canvas.reconnect_block.connect(_drag_manager.connect_block_canvas_signals)
	_drag_manager.block_dropped.connect(save_script)
	_drag_manager.block_modified.connect(save_script)

	if not _delete_node_button.icon:
		_delete_node_button.icon = _icon_delete
	if not _collapse_button.icon:
		_collapse_button.icon = _icon_collapse


func _on_undo_redo_version_changed():
	if _current_block_code_node == null:
		return

	var block_script: BlockScriptSerialization = _current_block_code_node.block_script
	_picker.block_script_selected(block_script)
	_title_bar.block_script_selected(block_script)
	_block_canvas.block_script_selected(block_script)


func _on_show_script_button_pressed():
	var block_script: BlockScriptSerialization = _current_block_code_node.block_script
	var script: String = _block_canvas.generate_script_from_current_window(block_script)

	script_window_requested.emit(script)


func _on_delete_node_button_pressed():
	var scene_root = EditorInterface.get_edited_scene_root()

	if not scene_root:
		return

	if not _current_block_code_node:
		return

	var dialog = ConfirmationDialog.new()
	var text_format: String = 'Delete block code ("{node}") for "{parent}"?'
	dialog.dialog_text = text_format.format({"node": _current_block_code_node.name, "parent": _current_block_code_node.get_parent().name})
	EditorInterface.popup_dialog_centered(dialog)
	dialog.connect("confirmed", _on_delete_dialog_confirmed.bind(_current_block_code_node))
	pass  # Replace with function body.


func _on_delete_dialog_confirmed(block_code_node: BlockCode):
	var parent_node = block_code_node.get_parent()

	if not parent_node:
		return

	undo_redo.create_action("Delete %s's block code script" % _current_block_code_node.get_parent().name, UndoRedo.MERGE_DISABLE, parent_node)
	undo_redo.add_do_property(block_code_node, "owner", null)
	undo_redo.add_do_method(parent_node, "remove_child", block_code_node)
	undo_redo.add_undo_method(parent_node, "add_child", block_code_node)
	undo_redo.add_undo_property(block_code_node, "owner", block_code_node.owner)
	undo_redo.add_undo_reference(block_code_node)
	undo_redo.commit_action()


func _try_migration():
	var version: int = _current_block_code_node.block_script.version
	if version == Constants.CURRENT_DATA_VERSION:
		# No migration needed.
		return
	push_warning("Migration not implemented from %d to %d" % [version, Constants.CURRENT_DATA_VERSION])


func switch_scene(scene_root: Node):
	_title_bar.scene_selected(scene_root)


func switch_block_code_node(block_code_node: BlockCode):
	var block_script: BlockScriptSerialization = block_code_node.block_script if block_code_node else null
	_current_block_code_node = block_code_node
	_delete_node_button.disabled = _current_block_code_node == null
	if _current_block_code_node != null:
		_try_migration()
	_picker.block_script_selected(block_script)
	_title_bar.block_script_selected(block_script)
	_block_canvas.block_script_selected(block_script)


func save_script():
	if _current_block_code_node == null:
		print("No script loaded to save.")
		return

	var scene_node = EditorInterface.get_edited_scene_root()

	if not BlockCodePlugin.is_block_code_editable(_current_block_code_node):
		print("Block code for {node} is not editable.".format({"node": _current_block_code_node}))
		return

	var block_script: BlockScriptSerialization = _current_block_code_node.block_script

	var resource_path_split = block_script.resource_path.split("::", true, 1)
	var resource_scene = resource_path_split[0]

	undo_redo.create_action("Modify %s's block code script" % _current_block_code_node.get_parent().name, UndoRedo.MERGE_DISABLE, _current_block_code_node)

	if resource_scene and resource_scene != scene_node.scene_file_path:
		# This resource is from another scene. Since the user is changing it
		# here, we'll make a copy for this scene rather than changing it in the
		# other scene file.
		undo_redo.add_undo_property(_current_block_code_node, "block_script", _current_block_code_node.block_script)
		block_script = block_script.duplicate(true)
		undo_redo.add_do_property(_current_block_code_node, "block_script", block_script)

	_block_canvas.rebuild_block_trees(undo_redo)
	var generated_script = _block_canvas.generate_script_from_current_window(block_script)
	if generated_script != block_script.generated_script:
		undo_redo.add_undo_property(block_script, "generated_script", block_script.generated_script)
		undo_redo.add_do_property(block_script, "generated_script", generated_script)

	block_script.version = Constants.CURRENT_DATA_VERSION

	undo_redo.commit_action()


func _input(event):
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				# Release focus
				var focused_node := get_viewport().gui_get_focus_owner()
				if focused_node:
					focused_node.release_focus()
			else:
				_drag_manager.drag_ended()

	if event is InputEventKey:
		if Input.is_key_pressed(KEY_CTRL) and event.pressed and event.keycode == KEY_BACKSLASH:
			_collapse_button.button_pressed = not _collapse_button.button_pressed
			toggle_collapse()


func _print_generated_script():
	if _current_block_code_node == null:
		return
	var block_script: BlockScriptSerialization = _current_block_code_node.block_script
	var script: String = _block_canvas.generate_script_from_current_window(block_script)
	print(script)
	print("Debug script! (not saved)")


func toggle_collapse():
	_collapsed = not _collapsed

	_collapse_button.icon = _icon_expand if _collapsed else _icon_collapse
	_picker.set_collapsed(_collapsed)
	_picker_split.collapsed = _collapsed


func _on_collapse_button_pressed():
	toggle_collapse()


func _on_block_canvas_add_block_code():
	var edited_node: Node = EditorInterface.get_inspector().get_edited_object() as Node
	var scene_root: Node = EditorInterface.get_edited_scene_root()

	if edited_node == null or scene_root == null:
		return

	var block_code = BlockCode.new()
	block_code.name = "BlockCode"

	undo_redo.create_action("Add block code for %s" % edited_node.name, UndoRedo.MERGE_DISABLE, edited_node)

	undo_redo.add_do_method(edited_node, "add_child", block_code, true)
	undo_redo.add_do_property(block_code, "owner", scene_root)
	undo_redo.add_do_method(self, "_select_block_code_node", edited_node)
	undo_redo.add_do_reference(block_code)
	undo_redo.add_undo_method(edited_node, "remove_child", block_code)
	undo_redo.add_undo_property(block_code, "owner", null)

	undo_redo.commit_action()


func _on_block_canvas_open_scene():
	var edited_node: Node = EditorInterface.get_inspector().get_edited_object() as Node

	if edited_node == null or edited_node.owner == null:
		return

	EditorInterface.open_scene_from_path(edited_node.scene_file_path)


func _on_block_canvas_replace_block_code():
	var edited_node: Node = EditorInterface.get_inspector().get_edited_object() as Node
	var scene_root: Node = EditorInterface.get_edited_scene_root()

	undo_redo.create_action("Replace block code %s" % edited_node.name, UndoRedo.MERGE_DISABLE, scene_root)

	# FIXME: When this is undone, the new state is not correctly shown in the
	#        editor due to an issue in Godot:
	#        <https://github.com/godotengine/godot/issues/45915>
	#        Ideally this should fix itself in a future version of Godot.

	undo_redo.add_do_method(scene_root, "set_editable_instance", edited_node, true)
	undo_redo.add_do_method(self, "_select_block_code_node", edited_node)
	undo_redo.add_undo_method(scene_root, "set_editable_instance", edited_node, false)

	undo_redo.commit_action()


func _select_block_code_node(edited_node: Node):
	var block_code_nodes = BlockCodePlugin.list_block_code_nodes_for_node(edited_node)
	if block_code_nodes.size() > 0:
		_set_selection([block_code_nodes.pop_front()])
	else:
		_set_selection([edited_node])


func _set_selection(nodes: Array[Node]):
	EditorInterface.get_selection().clear()
	for node in nodes:
		EditorInterface.get_selection().add_node(node)


func _create_variable(variable: VariableResource):
	if _current_block_code_node == null:
		print("No script loaded to add variable to.")
		return

	var block_script: BlockScriptSerialization = _current_block_code_node.block_script

	undo_redo.create_action("Create variable %s in %s's block code script" % [variable.var_name, _current_block_code_node.get_parent().name])
	undo_redo.add_undo_property(_current_block_code_node.block_script, "variables", _current_block_code_node.block_script.variables)

	var new_variables = block_script.variables.duplicate()
	new_variables.append(variable)

	undo_redo.add_do_property(_current_block_code_node.block_script, "variables", new_variables)
	undo_redo.commit_action()

	_picker.reload_variables(new_variables)
