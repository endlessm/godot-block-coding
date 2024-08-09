extends Object

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const Types = preload("res://addons/block_code/types/types.gd")

static var _catalog: Dictionary


static func setup():
	# Move dynamic block definitions here?
	pass


static func get_block(block_name: StringName):
	return _catalog.get(block_name)


static func has_block(block_name: StringName):
	return block_name in _catalog
