@tool
class_name Picker
extends MarginContainer

signal block_picked(block: Block)
signal variable_created(variable: VariableResource)

@onready var _block_list := %BlockList
@onready var _block_scroll := %BlockScroll
@onready var _category_list := %CategoryList
@onready var _widget_container := %WidgetContainer

var scroll_tween: Tween
var _variable_category_display: VariableCategoryDisplay = null


func bsd_selected(bsd: BlockScriptData):
	if not bsd:
		reset_picker()
		return

	var blocks_to_add: Array[BlockResource] = CategoryFactory.get_blocks_from_bsd(bsd)
	var categories_to_add: Array[BlockCategory] = CategoryFactory.get_categories_from_bsd(bsd)

	init_picker(blocks_to_add, categories_to_add)
	reload_variables(bsd.variables)


func reset_picker():
	for c in _category_list.get_children():
		c.queue_free()

	for c in _block_list.get_children():
		c.queue_free()


func init_picker(extra_blocks: Array[BlockResource] = [], extra_categories: Array[BlockCategory] = []):
	reset_picker()

	var blocks := CategoryFactory.get_general_blocks() + extra_blocks
	var block_categories := CategoryFactory.get_categories(blocks, extra_categories)

	for _category in block_categories:
		var category: BlockCategory = _category as BlockCategory

		var block_category_button: BlockCategoryButton = preload("res://addons/block_code/ui/picker/categories/block_category_button.tscn").instantiate()
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
		block_category_display.block_picked.connect(func(block: Block): block_picked.emit(block))

		_block_list.add_child(block_category_display)

		_block_scroll.scroll_vertical = 0


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
		for block_resource in CategoryFactory.get_variable_blocks(variables):
			var block: Block = CategoryFactory.construct_block_from_resource(block_resource)
			# HACK: Get color hardcoded
			block.color = CategoryFactory.BUILTIN_PROPS["Variables"].color
			_variable_category_display.variable_blocks.add_child(block)
			block.drag_started.connect(func(block: Block): block_picked.emit(block))
			if i % 2 == 0:
				var spacer := Control.new()
				spacer.custom_minimum_size.y = 12
				_variable_category_display.variable_blocks.add_child(spacer)
			i += 1
