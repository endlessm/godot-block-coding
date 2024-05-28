@tool
class_name Block
extends MarginContainer

signal drag_started(block: Block)

@export var block_name: String = ""

@export var snappable: bool = true

@export var bottom_snap_path: NodePath

var on_canvas: bool = false

var bottom_snap: SnapPoint


func _ready():
	bottom_snap = get_node_or_null(bottom_snap_path)


func _drag_started():
	drag_started.emit(self)


func disconnect_drag():
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
