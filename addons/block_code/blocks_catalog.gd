extends Object

const BlockDefinition = preload("res://addons/block_code/block_definition.gd")
const Types = preload("res://addons/block_code/types/types.gd")

static var _catalog: Dictionary


static func setup():
	if _catalog:
		return

	_catalog = {}
	var block_definition: BlockDefinition = BlockDefinition.new(&"ready_block", Types.BlockType.ENTRY)
	block_definition.label_template = "On Ready"
	block_definition.code_template = "func _ready():"
	block_definition.description = 'Attached blocks will be executed once when the node is "ready"'
	block_definition.category = "Lifecycle"
	_catalog[&"ready_block"] = block_definition

	block_definition = BlockDefinition.new(&"print", Types.BlockType.STATEMENT)
	block_definition.label_template = "print {text: STRING}"
	block_definition.code_template = "print({text})"
	block_definition.defaults = {"text": "Hello"}
	block_definition.description = "Print the text to output"
	block_definition.category = "Log"
	_catalog[&"print"] = block_definition


static func get_block(block_name: StringName):
	return _catalog.get(block_name)


static func has_block(block_name: StringName):
	return block_name in _catalog
