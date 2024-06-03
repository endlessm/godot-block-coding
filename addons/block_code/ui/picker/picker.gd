@tool
class_name Picker
extends MarginContainer

signal block_picked(block: Block)


func _ready():
	var block_categories := CategoryFactory.get_general_categories()

	for _category in block_categories:
		var category: BlockCategory = _category as BlockCategory

		var block_category_display := preload("res://addons/block_code/ui/picker/categories/block_category_display.tscn").instantiate()
		block_category_display.category = category

		%BlockList.add_child(block_category_display)

		for _block in category.block_list:
			var block: Block = _block as Block
			block.drag_started.connect(_block_picked)


func _block_picked(block: Block):
	block_picked.emit(block)
