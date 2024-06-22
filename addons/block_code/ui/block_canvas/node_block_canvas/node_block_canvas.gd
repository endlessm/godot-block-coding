@tool
class_name NodeBlockCanvas
extends BlockCanvas


func generate_script_from_current_window(script_inherits: String = ""):
	# TODO: implement multiple windows
	var current_window := _window

	var entry_blocks_by_entry_statement: Dictionary = {}

	for block in current_window.get_children():
		if !(block is Block):
			continue

		if block is EntryBlock:
			var entry_statement = block.get_entry_statement()
			if not entry_blocks_by_entry_statement.has(entry_statement):
				entry_blocks_by_entry_statement[entry_statement] = []
			entry_blocks_by_entry_statement[entry_statement].append(block)

	var script: String = ""

	script += "extends %s\n\n" % script_inherits

	script += "var VAR_DICT := {}\n\n"

	var init_func = InstructionTree.TreeNode.new("func _init():")

	for entry_statement in entry_blocks_by_entry_statement:
		var entry_blocks: Array[EntryBlock]
		entry_blocks.assign(entry_blocks_by_entry_statement[entry_statement])
		script += _generate_script_from_entry_blocks(entry_statement, entry_blocks, init_func)

	if init_func.children:
		script += InstructionTree.new().generate_text(init_func)

	return script


func _generate_script_from_entry_blocks(entry_statement: String, entry_blocks: Array[EntryBlock], init_func: InstructionTree.TreeNode) -> String:
	var script = entry_statement + "\n"
	var signal_node: InstructionTree.TreeNode
	var is_empty = true

	for entry_block in entry_blocks:
		var next_block := entry_block.bottom_snap.get_snapped_block()

		if next_block != null:
			var generator: InstructionTree = InstructionTree.new()
			var instruction_node: InstructionTree.TreeNode = next_block.get_instruction_node()
			var to_append := generator.generate_text(instruction_node, 1)
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
