extends Object

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")
const Types = preload("res://addons/block_code/types/types.gd")
const Constants = preload("res://addons/block_code/ui/constants.gd")
const VariableDefinition = preload("res://addons/block_code/code_generation/variable_definition.gd")

const SCENE_PER_TYPE = {
	Types.BlockType.ENTRY: preload("res://addons/block_code/ui/blocks/entry_block/entry_block.tscn"),
	Types.BlockType.STATEMENT: preload("res://addons/block_code/ui/blocks/statement_block/statement_block.tscn"),
	Types.BlockType.VALUE: preload("res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn"),
	Types.BlockType.CONTROL: preload("res://addons/block_code/ui/blocks/control_block/control_block.tscn"),
}


static func get_category_color(category: String) -> Color:
	var category_props: Dictionary = Constants.BUILTIN_CATEGORIES_PROPS.get(category, {})
	return category_props.get("color", Color.SLATE_GRAY)


static func instantiate_block(block_definition: BlockDefinition) -> Block:
	if block_definition == null:
		push_error("Cannot construct block from null block definition.")
		return null

	var scene = SCENE_PER_TYPE.get(block_definition.type)
	if scene == null:
		push_error("Cannot instantiate Block from type %s" % block_definition.type)
		return null

	var block = scene.instantiate()
	block.definition = block_definition
	return block


static func instantiate_block_by_name(block_name: StringName) -> Block:
	BlocksCatalog.setup()
	var block_definition: BlockDefinition = BlocksCatalog.get_block(block_name)
	if block_definition == null:
		push_error("The block %s is not in the catalog yet!" % block_name)
		return
	return instantiate_block(block_definition)


static func _get_builtin_parents(_class_name: String) -> Array[String]:
	var parents: Array[String] = []
	var current = _class_name

	while current != "":
		parents.append(current)
		current = ClassDB.get_parent_class(current)

	return parents


static func _get_custom_parent_class_name(_custom_class_name: String) -> String:
	for class_dict in ProjectSettings.get_global_class_list():
		if class_dict.class != _custom_class_name:
			continue
		var script = load(class_dict.path)
		var builtin_class = script.get_instance_base_type()
		return builtin_class
	return "Node"


static func _get_parents(_class_name: String) -> Array[String]:
	if ClassDB.class_exists(_class_name):
		return _get_builtin_parents(_class_name)
	var parents: Array[String] = [_class_name]
	var _parent_class_name = _get_custom_parent_class_name(_class_name)
	parents.append_array(_get_builtin_parents(_parent_class_name))
	return parents


static func instantiate_blocks_for_class(_class_name: String) -> Array[Block]:
	BlocksCatalog.setup()

	var blocks: Array[Block] = []
	for subclass in _get_parents(_class_name):
		for block_definition in BlocksCatalog.get_blocks_by_class(subclass):
			var b = instantiate_block(block_definition)
			blocks.append(b)

	return blocks


static func get_variable_block_definitions(variables: Array[VariableDefinition]) -> Array[BlockDefinition]:
	var block_definitions: Array[BlockDefinition] = []
	for variable: VariableDefinition in variables:
		var type_string: String = Types.VARIANT_TYPE_TO_STRING[variable.var_type]

		var b = BlockDefinition.new()
		b.name = "get_var_%s" % variable.var_name
		b.type = Types.BlockType.VALUE
		b.variant_type = variable.var_type
		b.display_template = variable.var_name
		b.code_template = variable.var_name
		block_definitions.append(b)

		b = BlockDefinition.new()
		b.name = "set_var_%s" % variable.var_name
		b.type = Types.BlockType.STATEMENT
		b.display_template = "Set %s to {value: %s}" % [variable.var_name, type_string]
		b.code_template = "%s = {value}" % [variable.var_name]
		block_definitions.append(b)

	return block_definitions


static func instantiate_variable_blocks(variables: Array[VariableDefinition]) -> Array[Block]:
	var blocks: Array[Block] = []
	for block_definition in get_variable_block_definitions(variables):
		var b = instantiate_block(block_definition)
		# HACK: Color the blocks since they are outside of the normal picker system
		b.color = Constants.BUILTIN_CATEGORIES_PROPS["Variables"].color
		blocks.append(b)

	return blocks


## Polyfill of Node.is_part_of_edited_scene(), available to GDScript in Godot 4.3+.
static func node_is_part_of_edited_scene(node: Node) -> bool:
	if not Engine.is_editor_hint():
		return false

	var tree := node.get_tree()
	if not tree or not tree.edited_scene_root:
		return false

	var edited_scene_parent := tree.edited_scene_root.get_parent()
	return edited_scene_parent and edited_scene_parent.is_ancestor_of(node)
