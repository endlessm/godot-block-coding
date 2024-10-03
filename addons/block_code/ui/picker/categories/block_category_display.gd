@tool
extends MarginContainer

signal block_picked(block: Block, offset: Vector2)

const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const Util = preload("res://addons/block_code/ui/util.gd")

@export var title: String:
	set = _set_title
@export var block_definitions: Array[BlockDefinition]:
	set = _set_block_definitions

@onready var _context := BlockEditorContext.get_default()

@onready var _label := %Label
@onready var _blocks_container := %BlocksContainer

var _blocks: Dictionary  # String, Block


func _ready():
	_label.text = title  # category.name if category != null else ""
	_update_label()
	_update_blocks()


func _set_title(value):
	title = value
	_update_label()


func _set_block_definitions(value):
	block_definitions = value
	_update_blocks()


func _update_label():
	if not _label:
		return

	_label.text = title


func _update_blocks():
	if not _blocks_container:
		return

	if not _context:
		return

	for block in _blocks.values():
		block.hide()

	for block_definition in block_definitions:
		var block = _get_or_create_block(block_definition)
		_blocks_container.move_child(block, -1)
		block.show()

	_blocks_container.visible = not block_definitions.is_empty()


func _get_or_create_block(block_definition: BlockDefinition) -> Block:
	var block: Block = _blocks.get(block_definition.name)

	if block == null:
		block = _context.block_script.instantiate_block(block_definition)
		block.can_delete = false
		block.drag_started.connect(func(block: Block, offset: Vector2): block_picked.emit(block, offset))
		_blocks_container.add_child(block)
		_blocks[block_definition.name] = block
	else:
		# If the block is being reused, make sure the context corresponds to
		# the current BlockCode node.
		block.refresh_context()

	return block
