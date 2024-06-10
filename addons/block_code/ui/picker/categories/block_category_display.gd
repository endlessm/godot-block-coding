@tool
class_name BlockCategoryDisplay
extends MarginContainer

var category: BlockCategory

@onready var _label := %Label
@onready var _blocks := %Blocks
@onready var _background := %Background


func _ready():
	if category:
		_label.text = category.name
		_background.color = category.color.darkened(0.7)
		_background.color.a = 0.3

		for _block in category.block_list:
			var block: Block = _block as Block

			block.color = category.color

			_blocks.add_child(block)
