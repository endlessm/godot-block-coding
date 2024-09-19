@tool
class_name Block
extends MarginContainer

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")

signal drag_started(block: Block)
signal modified

## Color of block (optionally used to draw block color)
@export var color: Color = Color(1., 1., 1.)

# FIXME Note: This used to be a NodePath. There is a bug in Godot 4.2 that causes the
# reference to not be set properly when the node is duplicated. Since we don't
# use the Node duplicate function anymore, this is okay.
# https://github.com/godotengine/godot/issues/82670
## The next block in the line of execution (can be null if end)
@export var bottom_snap: SnapPoint = null

## Snap point that holds blocks that should be nested under this block
@export var child_snap: SnapPoint = null

## The resource containing the definition of the block
@export var template_editor: TemplateEditor = null

## The scope of the block (statement of matching entry block)
@export var scope: String = ""

## The resource containing the definition of the block
@export var definition: BlockDefinition

## Whether the block can be deleted by the Delete key.
var can_delete: bool = true

@onready var _context := BlockEditorContext.get_default()


func _ready():
	focus_mode = FocusMode.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_template_editor()


func set_parameter_values_on_ready(raw_values: Dictionary):
	await ready
	set_parameter_values(raw_values)


func set_parameter_values(raw_values: Dictionary):
	template_editor.set_parameter_values(raw_values)


func get_parameter_values() -> Dictionary:
	return template_editor.get_parameter_values()


func _update_template_editor():
	if template_editor == null:
		return

	template_editor.format_string = definition.display_template if definition else ""
	template_editor.parameter_defaults = definition.get_defaults_for_node(_context.parent_node) if definition else {}
	if not template_editor.modified.is_connected(_on_template_editor_modified):
		template_editor.modified.connect(_on_template_editor_modified)


func _on_template_editor_modified():
	modified.emit()


func _gui_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_DELETE:
			# Always accept the Delete key so it doesn't propagate to the
			# BlockCode node in the scene tree.
			accept_event()

			if not can_delete:
				return

			var dialog := ConfirmationDialog.new()
			var num_blocks = _count_child_blocks(self) + 1
			# FIXME: Maybe this should use block_name or label, but that
			# requires one to be both unique and human friendly.
			if num_blocks > 1:
				dialog.dialog_text = "Delete %d blocks?" % num_blocks
			else:
				dialog.dialog_text = "Delete block?"
			dialog.confirmed.connect(remove_from_tree)
			EditorInterface.popup_dialog_centered(dialog)


func remove_from_tree():
	var parent = get_parent()
	if parent:
		parent.remove_child(self)
	queue_free()
	modified.emit()


static func get_block_class():
	push_error("Unimplemented.")


static func get_scene_path():
	push_error("Unimplemented.")


func _drag_started():
	drag_started.emit(self)


func disconnect_signals():
	var connections: Array = drag_started.get_connections()
	for c in connections:
		drag_started.disconnect(c.callable)


func _to_string():
	return "<{block_class}:{block_name}#{rid}>".format({"block_name": definition.name if definition else "", "block_class": get_block_class(), "rid": get_instance_id()})


func _make_custom_tooltip(for_text) -> Control:
	var tooltip = preload("res://addons/block_code/ui/tooltip/tooltip.tscn").instantiate()
	tooltip.text = for_text
	return tooltip


func _count_child_blocks(node: Node) -> int:
	var count = 0

	for child in node.get_children():
		if child is SnapPoint and child.has_snapped_block():
			count += 1
		count += _count_child_blocks(child)

	return count
