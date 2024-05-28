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

func get_instruction_node() -> InstructionTree.TreeNode:
	# Call child function? where's my abstract methods :(
	var main_instruction: String = call("get_instruction") as String
	
	var node: InstructionTree.TreeNode = InstructionTree.TreeNode.new(main_instruction)
	
	# TODO: blocks should be able to have multiple "main_instruction"s for each inner snap block
	# for example, if/else statements have two inner blocks
	for snap in snaps:
		var snapped_block: Block = snap.get_snapped_block()
		if snapped_block:
			node.add_child(snapped_block.get_instruction_node())
		
	if bottom_snap:
		var snapped_block: Block = bottom_snap.get_snapped_block()
		if snapped_block:
			node.next = snapped_block.get_instruction_node()
		
	return node

# Custom nodes will have a get_instruction() -> String
