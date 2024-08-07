@tool
extends MarginContainer

signal block_picked(block: Block)

const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")

var category: BlockCategory

@onready var _label := %Label
@onready var _blocks := %Blocks


func _ready():
	_label.text = category.name

	for block_definition in category.block_list:
		var block: Block = CategoryFactory.construct_block_from_definition(block_definition)

		block.color = category.color
		block.can_delete = false
		block.drag_started.connect(func(block: Block): block_picked.emit(block))

		_blocks.add_child(block)
