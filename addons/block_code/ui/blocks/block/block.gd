@tool
class_name Block
extends MarginContainer

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
@export var bottom_snap_path: NodePath

## The scope of the block (statement of matching entry block)
@export var scope: String = ""

var bottom_snap: SnapPoint


func _ready():
	bottom_snap = get_node_or_null(bottom_snap_path)


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


# Override this method to add more serialized properties
func get_serialized_props() -> Array:
	return serialize_props(["block_name", "label", "color", "block_type", "position", "scope"])


func serialize_props(prop_names: Array) -> Array:
	var pairs := []
	for p in prop_names:
		pairs.append([p, self.get(p)])
	return pairs
