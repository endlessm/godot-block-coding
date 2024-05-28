@tool
class_name Block
extends MarginContainer

signal drag_started(block: Block)

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

# Custom nodes will have a get_instruction_node() -> InstructionTree.TreeNode
