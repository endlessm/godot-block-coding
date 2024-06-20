@tool
class_name Picker
extends MarginContainer

signal block_picked(block: Block)

@onready var _block_list := %BlockList


func bsd_selected(bsd: BlockScriptData):
	if not bsd:
		reset_picker()
		return

	var categories_to_add: Array[BlockCategory] = []

	var found_simple_class_script = null
	for class_dict in ProjectSettings.get_global_class_list():
		if class_dict.class == bsd.script_inherits:
			var script = load(class_dict.path)
			if script.has_method("get_custom_blocks"):
				categories_to_add = script.get_custom_blocks()
				found_simple_class_script = script
			break

	var parent_class: String
	if found_simple_class_script:
		parent_class = str(found_simple_class_script.get_instance_base_type())
	else:  # Built in
		parent_class = bsd.script_inherits

	categories_to_add.append_array(CategoryFactory.get_inherited_categories(parent_class))

	init_picker(categories_to_add)


func reset_picker():
	for c in _block_list.get_children():
		c.queue_free()


func init_picker(extra_blocks: Array[BlockCategory] = []):
	reset_picker()

	var block_categories := CategoryFactory.get_general_categories()

	if extra_blocks.size() > 0:
		CategoryFactory.add_to_categories(block_categories, extra_blocks)

	for _category in block_categories:
		var category: BlockCategory = _category as BlockCategory

		var block_category_display := preload("res://addons/block_code/ui/picker/categories/block_category_display.tscn").instantiate()
		block_category_display.category = category

		_block_list.add_child(block_category_display)

		for _block in category.block_list:
			var block: Block = _block as Block
			block.drag_started.connect(_block_picked)


func _block_picked(block: Block):
	block_picked.emit(block)
