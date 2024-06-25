@tool
class_name MainPanel
extends Control

var eia: EditorInterfaceAccess

@onready var _picker: Picker = %Picker
@onready var _block_canvas: BlockCanvas = %NodeBlockCanvas
@onready var _drag_manager: DragManager = %DragManager
@onready var _title_bar: TitleBar = %TitleBar
@onready var _editor_inspector: EditorInspector = EditorInterface.get_inspector()

var block_code_tab: Button
var _current_block_code_node: BlockCode
var _scene_root: Node
var _block_code_nodes: Array

var undo_redo: EditorUndoRedoManager


func _ready():
	_picker.block_picked.connect(_drag_manager.copy_picked_block_and_drag)
	_block_canvas.reconnect_block.connect(_drag_manager.connect_block_canvas_signals)
	_drag_manager.block_dropped.connect(save_script)
	_drag_manager.block_modified.connect(save_script)

	eia = EditorInterfaceAccess.new()

	# Setup block scripting environment
	block_code_tab = eia.Utils.find_child_by_name(eia.context_switcher, "Block Code")
	undo_redo.version_changed.connect(_on_undo_redo_version_changed)


func _on_undo_redo_version_changed():
	if _current_block_code_node == null:
		return

	var block_script: BlockScriptData = _current_block_code_node.block_script
	_picker.bsd_selected(block_script)
	_title_bar.bsd_selected(block_script)
	_block_canvas.bsd_selected(block_script)


func _on_button_pressed():
	_print_generated_script()


func switch_scene(scene_root: Node):
	_title_bar.scene_selected(scene_root)


func switch_script(block_code_node: BlockCode):
	var block_script: BlockScriptData = block_code_node.block_script if block_code_node else null
	_current_block_code_node = block_code_node
	_picker.bsd_selected(block_script)
	_title_bar.bsd_selected(block_script)
	_block_canvas.bsd_selected(block_script)
	if block_code_node:
		block_code_tab.pressed.emit()


func save_script():
	if _current_block_code_node == null:
		print("No script loaded to save.")
		return

	var block_script: BlockScriptData = _current_block_code_node.block_script

	undo_redo.create_action("Modify %s's block code script" % _current_block_code_node.get_parent().name)
	undo_redo.add_undo_property(_current_block_code_node.block_script, "block_trees", _current_block_code_node.block_script.block_trees)
	undo_redo.add_undo_property(_current_block_code_node.block_script, "generated_script", _current_block_code_node.block_script.generated_script)

	var block_trees := _block_canvas.get_canvas_block_trees()
	var generated_script = _block_canvas.generate_script_from_current_window(block_script.script_inherits)
	block_script.block_trees = block_trees
	block_script.generated_script = generated_script

	undo_redo.add_do_property(_current_block_code_node.block_script, "block_trees", block_trees)
	undo_redo.add_do_property(_current_block_code_node.block_script, "generated_script", generated_script)
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


func _print_generated_script():
	if _current_block_code_node == null:
		return
	var block_script: BlockScriptData = _current_block_code_node.block_script
	var script: String = _block_canvas.generate_script_from_current_window(block_script.script_inherits)
	print(script)
	print("Debug script! (not saved)")
