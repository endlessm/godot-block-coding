@tool
class_name SimpleParameterBlock
extends BasicBlock

@export var text: String = ""

@onready var _input1 := %ParameterInput


func get_instruction_node() -> InstructionTree.TreeNode:
	var main_instruction: String = "print(%s)" % _input1.get_string()

	var node: InstructionTree.TreeNode = InstructionTree.TreeNode.new(main_instruction)

	if bottom_snap:
		var snapped_block: Block = bottom_snap.get_snapped_block()
		if snapped_block:
			node.next = snapped_block.get_instruction_node()

	return node
