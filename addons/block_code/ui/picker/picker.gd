@tool
extends MarginContainer

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const BlockCategoryButtonScene = preload("res://addons/block_code/ui/picker/categories/block_category_button.tscn")
const BlockCategoryButton = preload("res://addons/block_code/ui/picker/categories/block_category_button.gd")
const BlockCategoryDisplay = preload("res://addons/block_code/ui/picker/categories/block_category_display.gd")
const BlockCategoryDisplayScene = preload("res://addons/block_code/ui/picker/categories/block_category_display.tscn")
const VariableCategoryDisplayScene = preload("res://addons/block_code/ui/picker/categories/variable_category/variable_category_display.tscn")
const VariableDefinition = preload("res://addons/block_code/code_generation/variable_definition.gd")

const CATEGORY_ORDER_OVERRIDE = {
	"Lifecycle": [&"ready", &"process", &"queue_free"],
	"Loops": [&"for", &"while", &"break", &"continue", &"await_scene_ready"],
	"Log": [&"print"],
	"Communication | Methods": [&"define_method", &"call_method_group", &"call_method_node"],
	"Communication | Groups": [&"add_to_group", &"add_node_to_group", &"remove_from_group", &"remove_node_from_group", &"is_in_group", &"is_node_in_group"],
	"Variables": [&"vector2"],
	"Math": [&"add", &"subtract", &"multiply", &"divide", &"pow", &"randf_range", &"randi_range", &"sin", &"cos", &"tan"],
	"Logic | Conditionals": [&"if", &"else", &"else_if"],
	"Input": [&"is_input_actioned"],
	"Sounds": [&"load_sound", &"play_sound", &"pause_continue_sound", &"stop_sound"],
	"Graphics | Viewport": [&"viewport_width", &"viewport_height", &"viewport_center"],
}

signal block_picked(block: Block, offset: Vector2)
signal variable_created(variable: VariableDefinition)

@onready var _context := BlockEditorContext.get_default()

@onready var _block_list := %BlockList
@onready var _block_scroll := %BlockScroll
@onready var _category_list := %CategoryList
@onready var _widget_container := %WidgetContainer

var scroll_tween: Tween

var _category_buttons: Dictionary  # String, BlockCategoryButton
var _category_displays: Dictionary  # String, BlockCategoryDisplay


func _ready() -> void:
	_context.changed.connect(_on_context_changed)


func _on_context_changed():
	_block_scroll.scroll_vertical = 0
	_update_block_components()


func reload_blocks():
	_update_block_components()


static func _sort_blocks_by_list_order(block_definition_a, block_definition_b, name_order: Array) -> bool:
	var a_order = name_order.find(block_definition_a.name)
	var b_order = name_order.find(block_definition_b.name)
	return a_order >= 0 and a_order < b_order or b_order == -1


func _update_block_components():
	var block_categories: Array[BlockCategory]

	if _context.block_script:
		block_categories = _context.block_script.get_available_categories()
		block_categories.sort_custom(BlockCategory.sort_by_order)

	for block_category_button: BlockCategoryButton in _category_buttons.values():
		block_category_button.hide()

	for block_category_display: BlockCategoryDisplay in _category_displays.values():
		block_category_display.hide()

	for category in block_categories:
		var block_definitions := _context.block_script.get_blocks_in_category(category)
		var order_override = CATEGORY_ORDER_OVERRIDE.get(category.name)
		if order_override:
			block_definitions.sort_custom(_sort_blocks_by_list_order.bind(order_override))

		var block_category_button := _get_or_create_block_category_button(category)
		_category_list.move_child(block_category_button, -1)
		if category.name == "Variables" or not block_definitions.is_empty():
			block_category_button.show()

		var block_category_display := _get_or_create_block_category_display(category)
		block_category_display.block_definitions = block_definitions
		_block_list.move_child(block_category_display, -1)
		if category.name == "Variables" or not block_definitions.is_empty():
			block_category_display.show()


func _get_or_create_block_category_button(category: BlockCategory) -> BlockCategoryButton:
	var block_category_button: BlockCategoryButton = _category_buttons.get(category.name)

	if block_category_button == null:
		block_category_button = BlockCategoryButtonScene.instantiate()
		block_category_button.category = category
		block_category_button.selected.connect(_category_selected.bind(category.name))
		_category_list.add_child(block_category_button)
		_category_buttons[category.name] = block_category_button

	return block_category_button


func _get_or_create_block_category_display(category: BlockCategory) -> BlockCategoryDisplay:
	var block_category_display: BlockCategoryDisplay = _category_displays.get(category.name)

	if block_category_display == null:
		if category.name != "Variables":
			block_category_display = BlockCategoryDisplayScene.instantiate()
		else:
			block_category_display = VariableCategoryDisplayScene.instantiate()
			block_category_display.variable_created.connect(func(variable): variable_created.emit(variable))
		block_category_display.title = category.name if category else ""
		block_category_display.block_picked.connect(func(block: Block, offset: Vector2): block_picked.emit(block, offset))

		_block_list.add_child(block_category_display)
		_category_displays[category.name] = block_category_display

	return block_category_display


func scroll_to(y: float):
	if scroll_tween:
		scroll_tween.kill()
	scroll_tween = create_tween()
	scroll_tween.tween_property(_block_scroll, "scroll_vertical", y, 0.2)


func _category_selected(category_name: String):
	var block_category_display := _category_displays.get(category_name)
	if block_category_display:
		scroll_to(block_category_display.position.y)


func set_collapsed(collapsed: bool):
	_widget_container.visible = not collapsed
