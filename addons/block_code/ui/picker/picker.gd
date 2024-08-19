@tool
extends MarginContainer

const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const BlockCategoryButtonScene = preload("res://addons/block_code/ui/picker/categories/block_category_button.tscn")
const BlockCategoryButton = preload("res://addons/block_code/ui/picker/categories/block_category_button.gd")
const BlockCategoryDisplay = preload("res://addons/block_code/ui/picker/categories/block_category_display.gd")
const CategoryFactory = preload("res://addons/block_code/ui/picker/categories/category_factory.gd")
const VariableCategoryDisplay = preload("res://addons/block_code/ui/picker/categories/variable_category/variable_category_display.gd")

signal block_picked(block: Block)
signal variable_created(variable: VariableResource)

@onready var _block_list := %BlockList
@onready var _block_scroll := %BlockScroll
@onready var _category_list := %CategoryList
@onready var _widget_container := %WidgetContainer

var scroll_tween: Tween
var _variable_category_display: VariableCategoryDisplay = null


func block_script_selected(block_script: BlockScriptSerialization):
	if not block_script:
		reset_picker()
		return

	var categories_to_add: Array[BlockCategory] = []

	for class_dict in ProjectSettings.get_global_class_list():
		if class_dict.class == block_script.script_inherits:
			var script = load(class_dict.path)
			if script.has_method("get_custom_categories"):
				categories_to_add = script.get_custom_categories()
			if script.has_method("setup_custom_blocks"):
				script.setup_custom_blocks()
			break

	var blocks_to_add: Array[Block] = []
	blocks_to_add.append_array(CategoryFactory.get_inherited_blocks(block_script.script_inherits))

	init_picker(blocks_to_add, categories_to_add)
	reload_variables(block_script.variables)


func reset_picker():
	for c in _category_list.get_children():
		c.queue_free()

	for c in _block_list.get_children():
		c.queue_free()


func init_picker(extra_blocks: Array[Block] = [], extra_categories: Array[BlockCategory] = []):
	reset_picker()

	var blocks := CategoryFactory.get_general_blocks() + extra_blocks
	var block_categories := CategoryFactory.get_categories(blocks, extra_categories)

	for _category in block_categories:
		var category: BlockCategory = _category as BlockCategory

		var block_category_button: BlockCategoryButton = BlockCategoryButtonScene.instantiate()
		block_category_button.category = category
		block_category_button.selected.connect(_category_selected)

		_category_list.add_child(block_category_button)

		var block_category_display: BlockCategoryDisplay
		if category.name != "Variables":
			block_category_display = preload("res://addons/block_code/ui/picker/categories/block_category_display.tscn").instantiate()
		else:
			block_category_display = preload("res://addons/block_code/ui/picker/categories/variable_category/variable_category_display.tscn").instantiate()
			block_category_display.variable_created.connect(func(variable): variable_created.emit(variable))
			_variable_category_display = block_category_display

		block_category_display.category = category

		_block_list.add_child(block_category_display)

		for _block in category.block_list:
			var block: Block = _block as Block
			block.drag_started.connect(_block_picked)

			# Don't allow the block to be deleted while in the picker.
			block.can_delete = false

		_block_scroll.scroll_vertical = 0


func _block_picked(block: Block):
	block_picked.emit(block)


func scroll_to(y: float):
	if scroll_tween:
		scroll_tween.kill()
	scroll_tween = create_tween()
	scroll_tween.tween_property(_block_scroll, "scroll_vertical", y, 0.2)


func _category_selected(category: BlockCategory):
	for block_category_display in _block_list.get_children():
		if block_category_display.category.name == category.name:
			scroll_to(block_category_display.position.y)
			break


func set_collapsed(collapsed: bool):
	_widget_container.visible = not collapsed


func reload_variables(variables: Array[VariableResource]):
	if _variable_category_display:
		for c in _variable_category_display.variable_blocks.get_children():
			c.queue_free()

		var i := 1
		for block in CategoryFactory.get_variable_blocks(variables):
			_variable_category_display.variable_blocks.add_child(block)
			block.drag_started.connect(_block_picked)
			if i % 2 == 0:
				var spacer := Control.new()
				spacer.custom_minimum_size.y = 12
				_variable_category_display.variable_blocks.add_child(spacer)
			i += 1
