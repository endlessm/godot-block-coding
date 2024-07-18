extends Object


class TreeNode:
	var data: String
	var children: Array[TreeNode]
	var next: TreeNode

	func _init(_data: String):
		data = _data

	func add_child(node: TreeNode):
		children.append(node)


class IDHandler:
	static var counts: Dictionary = {}

	static func reset():
		counts = {}

	static func get_unique_id(str: String) -> int:
		if not counts.has(str):
			counts[str] = 0

		counts[str] += 1

		return counts[str]

	static func make_unique(formatted_string: String) -> String:
		var unique_string = formatted_string
		var regex = RegEx.new()
		regex.compile("\\b__[^\\s]+")
		var ids: Dictionary = {}
		for result in regex.search_all(formatted_string):
			var result_string = result.get_string()
			if not ids.has(result_string):
				ids[result_string] = get_unique_id(result_string)
			unique_string = unique_string.replace(result_string, result_string + "_%d" % ids[result_string])

		return unique_string


static func generate_text(root_node: TreeNode, start_depth: int = 0) -> String:
	var out = PackedStringArray()
	generate_text_recursive(root_node, start_depth, out)
	return "".join(out)


static func generate_text_recursive(node: TreeNode, depth: int, out: PackedStringArray):
	if node.data != "":
		out.append("\t".repeat(depth) + node.data + "\n")

	for c in node.children:
		generate_text_recursive(c, depth + 1, out)

	if node.next:
		generate_text_recursive(node.next, depth, out)


static func generate_script_from_nodes(nodes: Array[Node], bsd: BlockScriptData) -> String:
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

	script += "extends %s\n\n" % bsd.script_inherits

	for variable in bsd.variables:
		script += "var %s: %s\n\n" % [variable.var_name, type_string(variable.var_type)]

	script += "\n"

	var init_func = TreeNode.new("func _init():")

	for entry_statement in entry_blocks_by_entry_statement:
		var entry_blocks: Array[EntryBlock]
		entry_blocks.assign(entry_blocks_by_entry_statement[entry_statement])
		script += _generate_script_from_entry_blocks(entry_statement, entry_blocks, init_func)

	if init_func.children:
		script += generate_text(init_func)

	return script


static func _generate_script_from_entry_blocks(entry_statement: String, entry_blocks: Array[EntryBlock], init_func: TreeNode) -> String:
	var script = entry_statement + "\n"
	var signal_node: TreeNode
	var is_empty = true

	IDHandler.reset()

	for entry_block in entry_blocks:
		var next_block := entry_block.bottom_snap.get_snapped_block()

		if next_block != null:
			var instruction_node: TreeNode = next_block.get_instruction_node()
			var to_append := generate_text(instruction_node, 1)
			script += to_append
			script += "\n"
			is_empty = false

		if signal_node == null and entry_block.signal_name:
			signal_node = TreeNode.new("{0}.connect(_on_{0})".format([entry_block.signal_name]))

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
