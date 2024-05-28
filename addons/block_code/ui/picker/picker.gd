@tool
class_name Picker
extends MarginContainer

signal block_picked(block: Block)

const BLOCKS: Dictionary = {
	"control_block": preload("res://addons/block_code/ui/blocks/control_block/control_block.tscn"),
	"basic_block": preload("res://addons/block_code/ui/blocks/basic_block/basic_block.tscn"),
	"simple_text_block":
	preload("res://addons/block_code/ui/blocks/simple_text_block/simple_text_block.tscn"),
}


func _ready():
	var block_node: Block = BLOCKS["control_block"].instantiate()
	block_node.drag_started.connect(_block_picked)
	%BlockList.add_child(block_node)

	block_node = BLOCKS["basic_block"].instantiate()
	block_node.drag_started.connect(_block_picked)
	%BlockList.add_child(block_node)

	block_node = BLOCKS["simple_text_block"].instantiate()
	block_node.text = 'print("hi")'
	block_node.label = 'print "hi"'
	block_node.drag_started.connect(_block_picked)
	%BlockList.add_child(block_node)

	# entry
	block_node = BLOCKS["basic_block"].instantiate()
	block_node.block_name = "ready_block"
	block_node.label = "On Ready"
	block_node.color = Color("fa5956")
	block_node.drag_started.connect(_block_picked)
	%BlockList.add_child(block_node)

	block_node = BLOCKS["basic_block"].instantiate()
	block_node.block_name = "process_block"
	block_node.label = "On Process"
	block_node.color = Color("fa5956")
	block_node.drag_started.connect(_block_picked)
	%BlockList.add_child(block_node)


func _block_picked(block: Block):
	block_picked.emit(block)
