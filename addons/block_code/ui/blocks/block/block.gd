@tool
class_name Block
extends MarginContainer

const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")
const InstructionTree = preload("res://addons/block_code/instruction_tree/instruction_tree.gd")
const Types = preload("res://addons/block_code/types/types.gd")

signal drag_started(block: Block)
signal modified

## Name of the block to be referenced by others in search
@export var block_name: StringName

## Label of block (optionally used to draw block labels)
@export var label: String = ""

## Color of block (optionally used to draw block color)
@export var color: Color = Color(1., 1., 1.)

## Type of block to check if can be attached to snap point
@export var block_type: Types.BlockType = Types.BlockType.STATEMENT

## Category to add the block to
@export var category: String

## The next block in the line of execution (can be null if end)
@export var bottom_snap_path: NodePath:
	set = _set_bottom_snap_path

## The scope of the block (statement of matching entry block)
@export var scope: String = ""

## The resource containing the block properties and the snapped blocks
@export var resource: BlockSerialization

# FIXME: Add export to this variable and remove bottom_snap_path above.
# There is a bug in Godot 4.2 that prevents using SnapPoint directly:
# https://github.com/godotengine/godot/issues/82670
var bottom_snap: SnapPoint

## Whether the block can be deleted by the Delete key.
var can_delete: bool = true


func _set_bottom_snap_path(value: NodePath):
	bottom_snap_path = value
	bottom_snap = get_node_or_null(bottom_snap_path)


func _ready():
	if bottom_snap == null:
		_set_bottom_snap_path(bottom_snap_path)
	focus_mode = FocusMode.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_IGNORE


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


# Override this method to create custom block functionality
func get_instruction_node() -> InstructionTree.TreeNode:
	var node: InstructionTree.TreeNode = InstructionTree.TreeNode.new("")

	if bottom_snap:
		var snapped_block: Block = bottom_snap.get_snapped_block()
		if snapped_block:
			node.next = snapped_block.get_instruction_node()

	return node


func update_resources(undo_redo: EditorUndoRedoManager):
	if resource == null:
		var block_serialized_properties = BlockSerializedProperties.new(get_block_class(), get_serialized_props())
		resource = BlockSerialization.new(block_name, position, block_serialized_properties)
		return

	if resource.position != position:
		undo_redo.add_undo_property(resource, "position", resource.position)
		undo_redo.add_do_property(resource, "position", position)

	var serialized_props = get_serialized_props()

	if serialized_props != resource.block_serialized_properties.serialized_props:
		undo_redo.add_undo_property(resource.block_serialized_properties, "serialized_props", resource.block_serialized_properties.serialized_props)
		undo_redo.add_do_property(resource.block_serialized_properties, "serialized_props", serialized_props)


# Override this method to add more serialized properties
func get_serialized_props() -> Array:
	if not BlocksCatalog.has_block(block_name):
		return serialize_props(["block_name", "label", "color", "block_type", "position", "scope"])

	# TODO: Remove remaining serialization:
	# - Handle scope in a different way?
	return serialize_props(["scope"])


func _to_string():
	return "<{block_class}:{block_name}#{rid}>".format({"block_name": block_name, "block_class": get_block_class(), "rid": get_instance_id()})


func serialize_props(prop_names: Array) -> Array:
	var pairs := []
	for p in prop_names:
		pairs.append([p, self.get(p)])
	return pairs


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
