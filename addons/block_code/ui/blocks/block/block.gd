@tool
class_name Block
extends MarginContainer

@export var snap_paths: Array[NodePath]
@export var bottom_snap_path: NodePath

var on_canvas: bool = false

var snaps: Array[SnapPoint]
var bottom_snap: SnapPoint

signal drag_started(block: Block)

func _ready():
	for path in snap_paths:
		snaps.append(get_node(path))
	bottom_snap = get_node(bottom_snap_path)

func _drag_started():
	drag_started.emit(self)

func disconnect_drag():
	var connections: Array = drag_started.get_connections()
	for c in connections:
		drag_started.disconnect(c.callable)

# Custom nodes will have a get_instruction() -> InstructionTreeNode
