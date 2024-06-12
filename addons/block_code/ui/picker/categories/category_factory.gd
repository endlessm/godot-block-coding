class_name CategoryFactory
extends Object

const BLOCKS: Dictionary = {
	"entry_block": preload("res://addons/block_code/ui/blocks/entry_block/entry_block.tscn"),
	"control_block": preload("res://addons/block_code/ui/blocks/control_block/control_block.tscn"),
	"parameter_block": preload("res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn"),
	"statement_block": preload("res://addons/block_code/ui/blocks/statement_block/statement_block.tscn"),
}


static func get_general_categories() -> Array[BlockCategory]:
	var b: Block

	# Entry
	var entry_list: Array[Block] = []
	b = BLOCKS["entry_block"].instantiate()
	b.block_name = "ready_block"
	b.label = "On Ready"
	b.block_type = Types.BlockType.ENTRY
	entry_list.append(b)

	b = BLOCKS["entry_block"].instantiate()
	b.block_name = "process_block"
	b.label = "On Process"
	b.block_type = Types.BlockType.ENTRY
	entry_list.append(b)

	b = BLOCKS["entry_block"].instantiate()
	b.block_name = "physics_process_block"
	b.label = "On Physics Process"
	b.block_type = Types.BlockType.ENTRY
	entry_list.append(b)

	var entry_cat: BlockCategory = BlockCategory.new("Entry", entry_list, Color("fa5956"))

	# Control
	var control_list: Array[Block] = []

	b = BLOCKS["control_block"].instantiate()
	b.block_formats = ["if    {cond: BOOL}"]
	b.statements = ["if {cond}:"]
	control_list.append(b)

	b = BLOCKS["control_block"].instantiate()
	b.block_formats = ["if    {cond: BOOL}", "else"]
	b.statements = ["if {cond}:", "else:"]
	control_list.append(b)

	b = BLOCKS["control_block"].instantiate()
	b.block_formats = [
		"repeat {num: INT}",
	]
	b.statements = ["for i in {num}:"]
	control_list.append(b)

	var control_cat: BlockCategory = BlockCategory.new("Control", control_list, Color("ffad76"))

	# Test
	var test_list: Array[Block] = []

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "print {text: STRING}"
	b.statement = "print({text})"
	test_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.ENTRY
	b.block_format = "On body [body: NODE] entered"
	test_list.append(b)

	var test_cat: BlockCategory = BlockCategory.new("Test", test_list, Color("9989df"))

	# Signal
	var signal_list: Array[Block] = []

	b = BLOCKS["statement_block"].instantiate()
	b.block_name = "signal_block"
	b.block_type = Types.BlockType.ENTRY
	b.block_format = "On signal {signal: STRING}"
	signal_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Send signal {signal: STRING} to group {group: STRING}"
	b.statement = 'var signal_manager = get_tree().root.get_node_or_null("SignalManager")\n' + "if signal_manager:\n" + "\tsignal_manager.broadcast_signal({group}, {signal})"
	signal_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Add to group {group: STRING}"
	b.statement = "add_to_group({group})"
	signal_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Add {node: NODE} to group {group: STRING}"
	b.statement = "{node}.add_to_group({group})"
	signal_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Remove from group {group: STRING}"
	b.statement = "remove_from_group({group})"
	signal_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Remove {node: NODE} from group {group: STRING}"
	b.statement = "{node}.remove_from_group({group})"
	signal_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.block_type = Types.BlockType.BOOL
	b.block_format = "Is in group {group: STRING}"
	b.statement = "is_in_group({group})"
	signal_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.block_type = Types.BlockType.BOOL
	b.block_format = "Is {node: NODE} in group {group: STRING}"
	b.statement = "{node}.is_in_group({group})"
	signal_list.append(b)

	var signal_cat: BlockCategory = BlockCategory.new("Signal", signal_list, Color("f0c300"))

	# Variable
	var variable_list: Array[Block] = []

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Set String {var: STRING} {value: STRING}"
	b.statement = 'VAR_DICT["{var}"] = "{value}"'
	variable_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.block_format = "Get String {var: STRING}"
	b.statement = 'VAR_DICT["{var}"]'
	variable_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Set Int {var: STRING} {value: INT}"
	b.statement = 'VAR_DICT["{var}"] = {value}'
	variable_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.block_type = Types.BlockType.INT
	b.block_format = "Get Int {var: INT}"
	b.statement = 'VAR_DICT["{var}"]'
	variable_list.append(b)

	var variable_cat: BlockCategory = BlockCategory.new("Variables", variable_list, Color("4f975d"))

	# Math
	var math_list: Array[Block] = []

	b = BLOCKS["parameter_block"].instantiate()
	b.block_type = Types.BlockType.INT
	b.block_format = "{a: INT} + {b: INT}"
	b.statement = "({a} + {b})"
	math_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.block_type = Types.BlockType.INT
	b.block_format = "{a: INT} - {b: INT}"
	b.statement = "({a} - {b})"
	math_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.block_type = Types.BlockType.INT
	b.block_format = "{a: INT} * {b: INT}"
	b.statement = "({a} * {b})"
	math_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.block_type = Types.BlockType.INT
	b.block_format = "{a: INT} / {b: INT}"
	b.statement = "({a} / {b})"
	math_list.append(b)

	var math_cat: BlockCategory = BlockCategory.new("Math", math_list, Color("3042c5"))

	return [entry_cat, signal_cat, control_cat, test_cat, math_cat, variable_cat]


static func add_to_categories(main: Array[BlockCategory], addition: Array[BlockCategory]) -> Array[BlockCategory]:
	var matching := []

	for category in main:
		for add_category in addition:
			if category.name == add_category.name:
				matching.append(category.name)
				for block in add_category.block_list:
					category.block_list.append(block)

	for add_category in addition:
		if !matching.has(add_category.name):
			main.append(add_category)

	return main
