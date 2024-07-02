@tool
class_name BlockCategoryDisplay
extends MarginContainer

var category: BlockCategory

@onready var _label := %Label
@onready var _blocks := %Blocks


func _ready():
	_label.text = category.name

	for _block in category.block_list:
		var block: Block = _block as Block

		block.color = category.color

		_blocks.add_child(block)
