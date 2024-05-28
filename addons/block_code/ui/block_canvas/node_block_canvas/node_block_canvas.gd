@tool
class_name NodeBlockCanvas
extends BlockCanvas


func generate_script_from_current_window():
	# TODO: implement multiple windows
	var current_window := _window

	var blocks := current_window.get_children()

	var ready_nodes: Array[BasicBlock] = []
	var process_nodes: Array[BasicBlock] = []

	for c in blocks:
		if !(c is BasicBlock):
			continue

		match c.block_name:
			"ready_block":
				ready_nodes.append(c)
			"process_block":
				process_nodes.append(c)

	var script: String = ""

	script += "extends Node2D\n\n"

	for section in [["func _ready():", ready_nodes], ["func _process(_delta):", process_nodes]]:
		script += section[0] + "\n"

		var should_pass: bool = true
		for block in section[1]:
			if block.bottom_snap.get_snapped_block():
				should_pass = false
				break

		if should_pass:
			script += "\tpass\n"
		else:
			for block in section[1]:
				var generator: InstructionTree = InstructionTree.new()
				var instruction_node: InstructionTree.TreeNode = block.get_instruction_node()
				var to_append := generator.generate_text(instruction_node, 1)
				script += to_append

		script += "\n"

	return script
