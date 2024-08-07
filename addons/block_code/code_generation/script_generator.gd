extends Object

const Types = preload("res://addons/block_code/types/types.gd")
const ASTList = preload("res://addons/block_code/code_generation/ast_list.gd")
const BlockAST = preload("res://addons/block_code/code_generation/block_ast.gd")
const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")


static func generate_script(ast_list: ASTList, block_script: BlockScriptSerialization) -> String:
	var entry_asts: Array[BlockAST] = ast_list.get_top_level_nodes_of_type(Types.BlockType.ENTRY)

	var init_ast := BlockAST.new()
	init_ast.root = BlockAST.ASTNode.new()
	init_ast.root.data = BlockDefinition.new()
	init_ast.root.data.type = Types.BlockType.ENTRY
	init_ast.root.data.code_template = "func _init():"

	var combined_entry_asts = {}

	# Combine entry asts with same root statement
	for entry_ast in entry_asts:
		var statement = entry_ast.root.get_code(0)
		if not statement in combined_entry_asts:
			var new_ast := BlockAST.new()
			var root = BlockAST.ASTNode.new()
			root.data = entry_ast.root.data
			root.arguments = entry_ast.root.arguments
			root.children = entry_ast.root.children.duplicate()
			new_ast.root = root
			combined_entry_asts[statement] = new_ast
		else:
			combined_entry_asts[statement].root.children.append_array(entry_ast.root.children)

	# Connect signals on _init
	for entry_statement in combined_entry_asts:
		var entry_ast: BlockAST = combined_entry_asts[entry_statement]
		var signal_name = entry_ast.root.data.signal_name
		if signal_name != "":
			var signal_node := BlockAST.ASTNode.new()
			signal_node.data = BlockDefinition.new()
			signal_node.data.code_template = "{0}.connect(_on_{0})".format([signal_name])
			init_ast.root.children.append(signal_node)

	# Generate script extends statement
	var script := "extends %s\n\n" % block_script.script_inherits

	# Generate variables
	for variable in block_script.variables:
		script += "var %s: %s\n\n" % [variable.var_name, type_string(variable.var_type)]

	script += "\n"

	# Generate _init
	if not init_ast.root.children.is_empty():
		script += init_ast.get_code() + "\n"

	# Generate other entry methods
	for entry_statement in combined_entry_asts:
		var entry_ast: BlockAST = combined_entry_asts[entry_statement]
		script += entry_ast.get_code()
		script += "\n"

	return script
