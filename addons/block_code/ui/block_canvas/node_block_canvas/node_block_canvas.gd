@tool
class_name NodeBlockCanvas
extends BlockCanvas


func generate_script_from_current_window(script_inherits: String = ""):
	# TODO: implement multiple windows
	var current_window := _window

	var blocks := current_window.get_children()

	var entry_blocks: Array[EntryBlock] = []

	for c in blocks:
		if !(c is Block):
			continue

		if c is EntryBlock:
			entry_blocks.append(c)

	var script: String = ""

	script += "extends %s\n\n" % script_inherits

	script += "var VAR_DICT := {}\n\n"

	var init_func = InstructionTree.TreeNode.new("func _init():")

	for entry_block in entry_blocks:
		script += entry_block.get_entry_statement() + "\n"

		var next_block := entry_block.bottom_snap.get_snapped_block()

		if next_block == null:
			script += "\tpass\n"
		else:
			var generator: InstructionTree = InstructionTree.new()
			var instruction_node: InstructionTree.TreeNode = next_block.get_instruction_node()
			var to_append := generator.generate_text(instruction_node, 1)
			script += to_append

		script += "\n"

		if entry_block.signal_name:
			init_func.add_child(InstructionTree.TreeNode.new("{0}.connect(_on_{0})".format([entry_block.signal_name])))

	if init_func.children:
		script += InstructionTree.new().generate_text(init_func)

	return script
