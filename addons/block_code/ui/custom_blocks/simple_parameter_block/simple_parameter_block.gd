@tool
class_name SimpleParameterBlock
extends BasicBlock

@export var text: String = ""

var _input1text: String = ""

@onready var _input1 := %ParameterInput


func _ready():
	_input1.set_plain_text(_input1text)


func get_instruction_node() -> InstructionTree.TreeNode:
	var main_instruction: String = "print(%s)" % _input1.get_string()

	var node: InstructionTree.TreeNode = InstructionTree.TreeNode.new(main_instruction)

	if bottom_snap:
		var snapped_block: Block = bottom_snap.get_snapped_block()
		if snapped_block:
			node.next = snapped_block.get_instruction_node()

	return node


func get_serialized_props() -> Array:
	var props := super()
	props.append(["_input1text", _input1.get_plain_text()])
	return props


func get_scene_path():
	return "res://addons/block_code/ui/custom_blocks/simple_parameter_block/simple_parameter_block.tscn"
