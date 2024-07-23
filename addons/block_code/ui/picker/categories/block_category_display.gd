@tool
extends MarginContainer

const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")

var category: BlockCategory

@onready var _label := %Label
@onready var _blocks := %Blocks


func _ready():
	_label.text = category.name

	for _block in category.block_list:
		var block: Block = _block as Block

		block.color = category.color

		_blocks.add_child(block)
