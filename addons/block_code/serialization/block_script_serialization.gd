@tool
class_name BlockScriptSerialization
extends Resource

const ASTList = preload("res://addons/block_code/code_generation/ast_list.gd")
const BlockAST = preload("res://addons/block_code/code_generation/block_ast.gd")
const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")
const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlockSerialization = preload("res://addons/block_code/serialization/block_serialization.gd")
const BlockSerializationTree = preload("res://addons/block_code/serialization/block_serialization_tree.gd")
const ValueBlockSerialization = preload("res://addons/block_code/serialization/value_block_serialization.gd")
const VariableDefinition = preload("res://addons/block_code/code_generation/variable_definition.gd")

@export var script_inherits: String
@export var block_serialization_trees: Array[BlockSerializationTree]
@export var variables: Array[VariableDefinition]:
	set = _set_variables
@export var generated_script: String
@export var version: int

var _var_block_definitions: Dictionary  # String, BlockDefinition


func _init(
	p_script_inherits: String = "", p_block_serialization_trees: Array[BlockSerializationTree] = [], p_variables: Array[VariableDefinition] = [], p_generated_script: String = "", p_version = 0
):
	script_inherits = p_script_inherits
	block_serialization_trees = p_block_serialization_trees
	generated_script = p_generated_script
	variables = p_variables
	version = p_version


func _set_variables(value):
	variables = value
	_refresh_var_block_definitions()


func _refresh_var_block_definitions():
	_var_block_definitions.clear()
	for block_def in BlocksCatalog.get_variable_block_definitions(variables):
		_var_block_definitions[block_def.name] = block_def


func _get_block(block_name: StringName) -> BlockDefinition:
	var block_def: BlockDefinition = _var_block_definitions.get(block_name)
	if block_def == null:
		block_def = BlocksCatalog.get_block(block_name)
	return block_def


func get_definitions() -> Array[BlockDefinition]:
	for class_dict in ProjectSettings.get_global_class_list():
		if class_dict.class == script_inherits:
			var script = load(class_dict.path)
			if script.has_method("setup_custom_blocks"):
				script.setup_custom_blocks()
			break

	return BlocksCatalog.get_inherited_blocks(script_inherits)


func get_categories() -> Array[BlockCategory]:
	for class_dict in ProjectSettings.get_global_class_list():
		if class_dict.class == script_inherits:
			var script = load(class_dict.path)
			if script.has_method("get_custom_categories"):
				return script.get_custom_categories()

	return []


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
	ast_node.data = _get_block(node.name)

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
	ast_value_node.data = _get_block(value_node.name)

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
