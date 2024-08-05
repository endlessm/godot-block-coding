extends Object

const InstructionTree = preload("res://addons/block_code/instruction_tree/instruction_tree.gd")


static func generate_script_from_nodes(nodes: Array[Node], block_script: BlockScriptSerialization) -> String:
	var entry_blocks_by_entry_statement: Dictionary = {}

	for block in nodes:
		if !(block is Block):
			continue

		if block is EntryBlock:
			var entry_statement = block.get_entry_statement()
			if not entry_blocks_by_entry_statement.has(entry_statement):
				entry_blocks_by_entry_statement[entry_statement] = []
			entry_blocks_by_entry_statement[entry_statement].append(block)

	var script: String = ""

	script += "extends %s\n\n" % block_script.script_inherits

	for variable in block_script.variables:
		script += "var %s: %s\n\n" % [variable.var_name, type_string(variable.var_type)]

	script += "\n"

	var init_func = InstructionTree.TreeNode.new("func _init():")

	for entry_statement in entry_blocks_by_entry_statement:
		var entry_blocks: Array[EntryBlock]
		entry_blocks.assign(entry_blocks_by_entry_statement[entry_statement])
		script += _generate_script_from_entry_blocks(entry_statement, entry_blocks, init_func)

	if init_func.children:
		script += InstructionTree.generate_text(init_func)

	return script


static func _generate_script_from_entry_blocks(entry_statement: String, entry_blocks: Array[EntryBlock], init_func: InstructionTree.TreeNode) -> String:
	var script = entry_statement + "\n"
	var signal_node: InstructionTree.TreeNode
	var is_empty = true

	InstructionTree.IDHandler.reset()

	for entry_block in entry_blocks:
		var next_block := entry_block.bottom_snap.get_snapped_block()

		if next_block != null:
			var instruction_node: InstructionTree.TreeNode = next_block.get_instruction_node()
			var to_append := InstructionTree.generate_text(instruction_node, 1)
			script += to_append
			script += "\n"
			is_empty = false

		if signal_node == null and entry_block.signal_name:
			signal_node = InstructionTree.TreeNode.new("{0}.connect(_on_{0})".format([entry_block.signal_name]))

	if signal_node:
		init_func.add_child(signal_node)

	if is_empty:
		script += "\tpass\n\n"

	return script


## Returns the scope of the first non-empty scope child block
static func get_tree_scope(node: Node) -> String:
	if node is Block:
		if node.scope != "":
			return node.scope

	for c in node.get_children():
		var scope := get_tree_scope(c)
		if scope != "":
			return scope
	return ""


## Get the nearest Block node that is a parent of the provided node.
static func get_parent_block(node: Node) -> Block:
	var parent = node.get_parent()
	while parent and not parent is Block:
		parent = parent.get_parent()
	return parent as Block
