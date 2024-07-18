@tool
class_name BlockCategoryDisplay
extends MarginContainer

signal block_picked(block: Block)

var category: BlockCategory

@onready var _label := %Label
@onready var _blocks := %Blocks


func _ready():
	_label.text = category.name

	for block_resource in category.block_list:
		var block: Block = CategoryFactory.construct_block_from_resource(block_resource)

		block.color = category.color
		block.drag_started.connect(func(block: Block): block_picked.emit(block))

		_blocks.add_child(block)
