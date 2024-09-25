@tool
class_name BlockScriptSerialization
extends Resource

const ASTList = preload("res://addons/block_code/code_generation/ast_list.gd")
const BlockAST = preload("res://addons/block_code/code_generation/block_ast.gd")
const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlockSerialization = preload("res://addons/block_code/serialization/block_serialization.gd")
const BlockSerializationTree = preload("res://addons/block_code/serialization/block_serialization_tree.gd")
const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")
const CategoryFactory = preload("res://addons/block_code/ui/picker/categories/category_factory.gd")
const Types = preload("res://addons/block_code/types/types.gd")
const ValueBlockSerialization = preload("res://addons/block_code/serialization/value_block_serialization.gd")
const VariableDefinition = preload("res://addons/block_code/code_generation/variable_definition.gd")

const SCENE_PER_TYPE = {
	Types.BlockType.ENTRY: preload("res://addons/block_code/ui/blocks/entry_block/entry_block.tscn"),
	Types.BlockType.STATEMENT: preload("res://addons/block_code/ui/blocks/statement_block/statement_block.tscn"),
	Types.BlockType.VALUE: preload("res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn"),
	Types.BlockType.CONTROL: preload("res://addons/block_code/ui/blocks/control_block/control_block.tscn"),
}

@export var script_inherits: String
@export var block_serialization_trees: Array[BlockSerializationTree]
@export var variables: Array[VariableDefinition]:
	set = _set_variables
@export var generated_script: String
@export var version: int

var _available_blocks: Array[BlockDefinition]
var _categories: Array[BlockCategory]


func _init(
	p_script_inherits: String = "", p_block_serialization_trees: Array[BlockSerializationTree] = [], p_variables: Array[VariableDefinition] = [], p_generated_script: String = "", p_version = 0
):
	script_inherits = p_script_inherits
	block_serialization_trees = p_block_serialization_trees
	generated_script = p_generated_script
	variables = p_variables
	version = p_version


func initialize():
	_update_block_definitions()


func _set_variables(value):
	variables = value
	_update_block_definitions()


func instantiate_block(block_definition: BlockDefinition) -> Block:
	if block_definition == null:
		push_error("Cannot construct block from null block definition.")
		return null

	var scene := SCENE_PER_TYPE.get(block_definition.type)
	if scene == null:
		push_error("Cannot instantiate Block from type %s" % block_definition.type)
		return null

	var block_category := _get_category_by_name(block_definition.category)

	var block: Block = scene.instantiate()
	block.definition = block_definition
	block.color = block_category.color if block_category else Color.WHITE
	return block


func instantiate_block_by_name(block_name: String) -> Block:
	var block_definition := get_block_definition(block_name)

	if block_definition == null:
		push_warning("Cannot find a block definition for %s" % block_name)
		return null

	return instantiate_block(block_definition)


func get_block_definition(block_name: String) -> BlockDefinition:
	var split := block_name.split(":", true, 1)

	if len(split) > 1:
		return _get_parameter_block_definition(split[0], split[1])

	var block_definition = _get_base_block_definition(block_name)

	if block_definition == null:
		# FIXME: This is a workaround for old-style output block references.
		#        These were generated ahead of time using a block name that has
		#        a "_" before the parameter name. Now, these parameter blocks
		#        are generated on demand for any block name containing a ":".
		#        Please remove this fallback when it is no longer necessary.
		split = block_name.rsplit("_", true, 1)
		return _get_parameter_block_definition(split[0], split[1])

	return block_definition


func _get_base_block_definition(block_name: String) -> BlockDefinition:
	for block_definition in _available_blocks:
		if block_definition.name == block_name:
			return block_definition
	return null


func _get_parameter_block_definition(block_name: String, parameter_name: String) -> BlockDefinition:
	var base_block_definition := _get_base_block_definition(block_name)

	if base_block_definition == null:
		return null

	var parent_out_parameters = base_block_definition.get_output_parameters()

	if not parent_out_parameters.has(parameter_name):
		push_error("The parameter name %s is not an output parameter in %s." % [parameter_name, block_name])
		return null

	var parameter_type: Variant.Type = parent_out_parameters[parameter_name]

	var block_definition := BlockDefinition.new()
	block_definition.name = &"%s:%s" % [block_name, parameter_name]
	block_definition.target_node_class = base_block_definition.target_node_class
	block_definition.category = base_block_definition.category
	block_definition.type = Types.BlockType.VALUE
	block_definition.variant_type = parameter_type
	block_definition.display_template = parameter_name
	block_definition.code_template = parameter_name
	block_definition.scope = base_block_definition.code_template

	return block_definition


func _update_block_definitions():
	_available_blocks.clear()
	_available_blocks.append_array(_get_inherited_block_definitions())
	_available_blocks.append_array(_get_variable_block_definitions())

	var custom_categories: Array[BlockCategory] = _get_custom_categories()
	_categories = CategoryFactory.get_all_categories(custom_categories)


func _get_custom_categories() -> Array[BlockCategory]:
	for class_dict in ProjectSettings.get_global_class_list():
		if class_dict.class == script_inherits:
			var script = load(class_dict.path)
			if script.has_method("get_custom_categories"):
				return script.get_custom_categories()

	return []


func get_available_blocks() -> Array[BlockDefinition]:
	return _available_blocks


func get_available_categories() -> Array[BlockCategory]:
	# As a special case, the Variables category is always available.
	return _categories.filter(func(category): return category.name == "Variables" or _available_blocks.any(BlockDefinition.has_category.bind(category.name)))


func get_blocks_in_category(category: BlockCategory) -> Array[BlockDefinition]:
	if not category:
		return []
	return _available_blocks.filter(BlockDefinition.has_category.bind(category.name))


func _get_category_by_name(category_name: String) -> BlockCategory:
	return _categories.filter(func(category): return category.name == category_name).front()


func load_object_script() -> Object:
	for class_dict in ProjectSettings.get_global_class_list():
		if class_dict.class == script_inherits:
			return load(class_dict.path) as Object
	return null


func _get_inherited_block_definitions() -> Array[BlockDefinition]:
	return BlocksCatalog.get_inherited_blocks(script_inherits)


func _get_variable_block_definitions() -> Array[BlockDefinition]:
	return BlocksCatalog.get_variable_block_definitions(variables)


func generate_ast_list() -> ASTList:
	var ast_list := ASTList.new()
	for tree in block_serialization_trees:
		var ast: BlockAST = _tree_to_ast(tree)
		ast_list.append(ast, tree.canvas_position)
	return ast_list


func _tree_to_ast(tree: BlockSerializationTree) -> BlockAST:
	var ast: BlockAST = BlockAST.new()
	ast.root = _block_to_ast_node(tree.root)
	return ast


func _block_to_ast_node(node: BlockSerialization) -> BlockAST.ASTNode:
	var ast_node := BlockAST.ASTNode.new()
	ast_node.data = get_block_definition(node.name)

	for arg_name in node.arguments:
		var argument = node.arguments[arg_name]
		if argument is ValueBlockSerialization:
			argument = _value_to_ast_value(argument)
		ast_node.arguments[arg_name] = argument

	var children: Array[BlockAST.ASTNode]
	for c in node.children:
		children.append(_block_to_ast_node(c))
	ast_node.children = children

	return ast_node


func _value_to_ast_value(value_node: ValueBlockSerialization) -> BlockAST.ASTValueNode:
	var ast_value_node := BlockAST.ASTValueNode.new()
	ast_value_node.data = get_block_definition(value_node.name)

	for arg_name in value_node.arguments:
		var argument = value_node.arguments[arg_name]
		if argument is ValueBlockSerialization:
			argument = _value_to_ast_value(argument)
		ast_value_node.arguments[arg_name] = argument

	return ast_value_node


func update_from_ast_list(ast_list: ASTList):
	var trees: Array[BlockSerializationTree]
	for ast_pair in ast_list.array:
		var root := _block_from_ast_node(ast_pair.ast.root)
		var tree := BlockSerializationTree.new(root, ast_pair.canvas_position)
		trees.append(tree)
	block_serialization_trees = trees


func _block_from_ast_node(ast_node: BlockAST.ASTNode) -> BlockSerialization:
	var block := BlockSerialization.new(ast_node.data.name)

	for arg_name in ast_node.arguments:
		var argument = ast_node.arguments[arg_name]
		if argument is BlockAST.ASTValueNode:
			argument = _value_from_ast_value(argument)
		block.arguments[arg_name] = argument

	var children: Array[BlockSerialization]
	for c in ast_node.children:
		children.append(_block_from_ast_node(c))
	block.children = children

	return block


func _value_from_ast_value(ast_node: BlockAST.ASTValueNode) -> ValueBlockSerialization:
	var value := ValueBlockSerialization.new(ast_node.data.name)

	for arg_name in ast_node.arguments:
		var argument = ast_node.arguments[arg_name]
		if argument is BlockAST.ASTValueNode:
			argument = _value_from_ast_value(argument)
		value.arguments[arg_name] = argument

	return value
