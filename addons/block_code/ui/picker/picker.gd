@tool
extends MarginContainer

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const BlockCategoryButtonScene = preload("res://addons/block_code/ui/picker/categories/block_category_button.tscn")
const BlockCategoryButton = preload("res://addons/block_code/ui/picker/categories/block_category_button.gd")
const BlockCategoryDisplay = preload("res://addons/block_code/ui/picker/categories/block_category_display.gd")
const Util = preload("res://addons/block_code/ui/util.gd")
const VariableCategoryDisplay = preload("res://addons/block_code/ui/picker/categories/variable_category/variable_category_display.gd")
const VariableDefinition = preload("res://addons/block_code/code_generation/variable_definition.gd")

signal block_picked(block: Block)
signal variable_created(variable: VariableDefinition)

@onready var _context := BlockEditorContext.get_default()

@onready var _block_list := %BlockList
@onready var _block_scroll := %BlockScroll
@onready var _category_list := %CategoryList
@onready var _widget_container := %WidgetContainer

var scroll_tween: Tween
var _variable_category_display: VariableCategoryDisplay = null


func _ready() -> void:
	_context.changed.connect(_on_context_changed)


func _on_context_changed():
	_block_scroll.scroll_vertical = 0
	_update_block_components()


func reload_blocks():
	_update_block_components()


func _update_block_components():
	# FIXME: Instead, we should reuse existing CategoryList and BlockList components.
	_reset_picker()

	if not _context.block_script:
		return

	var block_categories := _context.block_script.get_available_categories()

	block_categories.sort_custom(BlockCategory.sort_by_order)

	for category in block_categories:
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
		block_category_display.block_picked.connect(func(block: Block): block_picked.emit(block))

		_block_list.add_child(block_category_display)


func _reset_picker():
	for node in _category_list.get_children():
		_category_list.remove_child(node)
		node.queue_free()

	for node in _block_list.get_children():
		_block_list.remove_child(node)
		node.queue_free()


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
