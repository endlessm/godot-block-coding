class_name ScriptGenerator
extends Object


static func generate_script(ast_list: ASTList, bsd: BlockScriptData) -> String:
	var entry_asts: Array[BlockAST] = ast_list.get_top_level_nodes_of_type(Types.BlockType.ENTRY)

	var init_ast := BlockAST.new()
	init_ast.root = BlockAST.ASTNode.new()
	init_ast.root.data = BlockResource.new()
	init_ast.root.data.statement = "func _init():"

	var combined_entry_asts = {}

	# Combine entry asts with same root statement
	for entry_ast in entry_asts:
		var statement = entry_ast.root.data.statement
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
			signal_node.data = BlockResource.new()
			signal_node.data.statement = "{0}.connect(_on_{0})".format([signal_name])
			init_ast.root.children.append(signal_node)

	# Generate script extends statement
	var script := "extends %s\n\n" % bsd.script_inherits

	# Generate variables
	for variable in bsd.variables:
		script += "var %s: %s\n\n" % [variable.var_name, type_string(variable.var_type)]

	script += "\n"

	# Generate _init
	script += init_ast.get_code() + "\n"

	# Generate other entry methods
	for entry_statement in combined_entry_asts:
		var entry_ast: BlockAST = combined_entry_asts[entry_statement]
		script += entry_ast.get_code()
		script += "\n"

	return script
