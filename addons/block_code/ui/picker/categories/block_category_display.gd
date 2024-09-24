@tool
extends MarginContainer

signal block_picked(block: Block)

const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const Util = preload("res://addons/block_code/ui/util.gd")

const CATEGORY_ORDER_OVERRIDE = {
	"Lifecycle":
	[
		"ready",
		"process",
	],
	"Logic | Conditionals":
	[
		"if",
		"else",
		"else_if",
	]
}

var category: BlockCategory

@onready var _context := BlockEditorContext.get_default()

@onready var _label := %Label
@onready var _blocks := %Blocks


func _ready():
	_label.text = category.name if category != null else ""

	if _context.block_script == null:
		return

	if category == null:
		return

	var category_order = CATEGORY_ORDER_OVERRIDE.get(category.name)
	var block_definitions = _context.block_script.get_blocks_in_category(category)
	if category_order:
		block_definitions.sort_custom(_sort_blocks_by_list_order.bind(category_order))

	for block_definition in block_definitions:
		var block: Block = _context.block_script.instantiate_block(block_definition)

		block.color = category.color
		block.can_delete = false
		block.drag_started.connect(func(block: Block): block_picked.emit(block))

		_blocks.add_child(block)


static func _sort_blocks_by_list_order(block_definition_a, block_definition_b, name_order: Array) -> bool:
	var a_order = name_order.find(block_definition_a.name)
	var b_order = name_order.find(block_definition_b.name)
	return a_order >= 0 and a_order < b_order or b_order == -1
