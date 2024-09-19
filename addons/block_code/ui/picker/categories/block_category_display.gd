@tool
extends MarginContainer

signal block_picked(block: Block)

const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const Util = preload("res://addons/block_code/ui/util.gd")

var category: BlockCategory

@onready var _context := BlockEditorContext.get_default()

@onready var _label := %Label
@onready var _blocks := %Blocks


func _ready():
	_label.text = category.name if category != null else ""

	if _context.block_script == null:
		return

	for block_definition in _context.block_script.get_blocks_in_category(category):
		var block: Block = _context.block_script.instantiate_block(block_definition)

		block.color = category.color
		block.can_delete = false
		block.drag_started.connect(func(block: Block): block_picked.emit(block))

		_blocks.add_child(block)
