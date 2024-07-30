@tool
class_name Block
extends MarginContainer

const InstructionTree = preload("res://addons/block_code/instruction_tree/instruction_tree.gd")
const Types = preload("res://addons/block_code/types/types.gd")

signal drag_started(block: Block)
signal modified

## Name of the block to be referenced by others in search
@export var block_name: String = ""

## Label of block (optionally used to draw block labels)
@export var label: String = ""

## Color of block (optionally used to draw block color)
@export var color: Color = Color(1., 1., 1.)

## Type of block to check if can be attached to snap point
@export var block_type: Types.BlockType = Types.BlockType.EXECUTE

## Category to add the block to
@export var category: String

## The next block in the line of execution (can be null if end)
@export var bottom_snap_path: NodePath:
	set = _set_bottom_snap_path

## The scope of the block (statement of matching entry block)
@export var scope: String = ""

## The resource containing the block properties and the snapped blocks
@export var resource: SerializedBlockTreeNode

# FIXME: Add export to this variable and remove bottom_snap_path above.
# There is a bug in Godot 4.2 that prevents using SnapPoint directly:
# https://github.com/godotengine/godot/issues/82670
var bottom_snap: SnapPoint


func _set_bottom_snap_path(value: NodePath):
	bottom_snap_path = value
	bottom_snap = get_node_or_null(bottom_snap_path)


func _ready():
	if bottom_snap == null:
		_set_bottom_snap_path(bottom_snap_path)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


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
		var serialized_block = SerializedBlock.new(get_block_class(), get_serialized_props())
		resource = SerializedBlockTreeNode.new(serialized_block)
		return

	var serialized_props = get_serialized_props()
	if serialized_props != resource.serialized_block.serialized_props:
		undo_redo.add_undo_property(resource.serialized_block, "serialized_props", resource.serialized_block.serialized_props)
		undo_redo.add_do_property(resource.serialized_block, "serialized_props", serialized_props)


# Override this method to add more serialized properties
func get_serialized_props() -> Array:
	return serialize_props(["block_name", "label", "color", "block_type", "position", "scope"])


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
