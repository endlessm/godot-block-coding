@tool
class_name SimpleTextBlock
extends BasicBlock

@export var text: String = ""


func get_instruction_node() -> InstructionTree.TreeNode:
	var main_instruction: String = text

	var node: InstructionTree.TreeNode = InstructionTree.TreeNode.new(main_instruction)

	if bottom_snap:
		var snapped_block: Block = bottom_snap.get_snapped_block()
		if snapped_block:
			node.next = snapped_block.get_instruction_node()

	return node


func get_scene_path():
	return "res://addons/block_code/ui/blocks/simple_text_block/simple_text_block.tscn"
