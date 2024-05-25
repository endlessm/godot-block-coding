@tool
class_name Picker
extends MarginContainer

signal block_picked(block: Block)

var block_list: Array = [1,2]

func _ready():
	for block in block_list:
		var block_node: Block = preload("res://addons/block_code/ui/blocks/control_block/control_block.tscn").instantiate()
		block_node.drag_started.connect(_block_picked)
		%BlockList.add_child(block_node)


func _block_picked(block: Block):
	block_picked.emit(block)
