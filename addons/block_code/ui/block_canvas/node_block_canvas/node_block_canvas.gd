@tool
class_name NodeBlockCanvas
extends BlockCanvas


func generate_script_from_current_window(script_inherits: String = ""):
	# TODO: implement multiple windows
	var current_window := _window

	var blocks := current_window.get_children()

	var ready_nodes: Array[EntryBlock] = []
	var process_nodes: Array[EntryBlock] = []
	var physics_process_nodes: Array[EntryBlock] = []
	var signal_nodes: Array[StatementBlock] = []

	for c in blocks:
		if !(c is Block):
			continue

		match c.block_name:
			"ready_block":
				ready_nodes.append(c)
			"process_block":
				process_nodes.append(c)
			"physics_process_block":
				physics_process_nodes.append(c)
			"signal_block":
				signal_nodes.append(c)

	var script: String = ""

	script += "extends %s\n\n" % script_inherits

	script += "var VAR_DICT := {}\n\n"

	var node_groups = [["func _ready():", ready_nodes], ["func _process(_delta):", process_nodes], ["func _physics_process(_delta):", physics_process_nodes]]

	# Get signal entries
	var signal_groups: Dictionary = {}
	for signal_node in signal_nodes:
		# Little bit hacky to get first param
		var signal_name: String = signal_node.param_name_input_pairs[0][1].get_plain_text()
		if signal_groups.has(signal_name):
			signal_groups[signal_name].append(signal_node)
		else:
			signal_groups[signal_name] = [signal_node]

	for signal_name in signal_groups:
		node_groups.append(["func signal_%s():" % signal_name, signal_groups[signal_name]])

	for section in node_groups:
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

		#script += "\n\tsuper()\n\n"
		script += "\n"

	return script
