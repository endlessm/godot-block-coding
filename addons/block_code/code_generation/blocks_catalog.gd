extends Object

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const Types = preload("res://addons/block_code/types/types.gd")
const Util = preload("res://addons/block_code/code_generation/util.gd")

const _BLOCKS_PATH = "res://addons/block_code/blocks/"

static var _catalog: Dictionary
static var _by_class_name: Dictionary


static func setup():
	if _catalog:
		return

	_catalog = {}

	var definition_files = Util.get_files_in_dir_recursive(_BLOCKS_PATH, "*.tres")
	for file in definition_files:
		var block_definition: BlockDefinition = load(file)
		_catalog[block_definition.name] = block_definition
		var target = block_definition.target_node_class
		if not target:
			continue
		if not target in _by_class_name:
			_by_class_name[target] = {}
		_by_class_name[target][block_definition.name] = block_definition


static func get_block(block_name: StringName):
	return _catalog.get(block_name)


static func has_block(block_name: StringName):
	return block_name in _catalog


static func get_blocks_by_class(_class_name: String):
	if not _class_name in _by_class_name:
		return []
	var block_definitions = _by_class_name[_class_name] as Dictionary
	return block_definitions.values()
