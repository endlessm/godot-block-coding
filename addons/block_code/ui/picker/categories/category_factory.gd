class_name CategoryFactory
extends Object

const BLOCKS: Dictionary = {
	"basic_block": preload("res://addons/block_code/ui/blocks/basic_block/basic_block.tscn"),
	"control_block": preload("res://addons/block_code/ui/blocks/control_block/control_block.tscn"),
	"parameter_block": preload("res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn"),
	"statement_block": preload("res://addons/block_code/ui/blocks/statement_block/statement_block.tscn"),
	"entry_block": preload("res://addons/block_code/ui/blocks/entry_block/entry_block.tscn"),
}


static func get_general_categories() -> Array[BlockCategory]:
	var b: Block

	# Lifecycle
	var lifecycle_list: Array[Block] = []
	b = BLOCKS["entry_block"].instantiate()
	b.block_name = "ready_block"
	b.block_format = "On Ready"
	b.statement = "func _ready():"
	lifecycle_list.append(b)

	b = BLOCKS["entry_block"].instantiate()
	b.block_name = "process_block"
	b.block_format = "On Process"
	b.statement = "func _process(delta):"
	lifecycle_list.append(b)

	b = BLOCKS["entry_block"].instantiate()
	b.block_name = "physics_process_block"
	b.block_format = "On Physics Process"
	b.statement = "func _physics_process(delta):"
	lifecycle_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Queue Free"
	b.statement = "queue_free()"
	lifecycle_list.append(b)

	var lifecycle_category: BlockCategory = BlockCategory.new("Lifecycle", lifecycle_list, Color("fa5956"))

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
	b.block_formats = ["repeat {num: INT}"]
	b.statements = ["for i in {num}:"]
	control_list.append(b)

	b = BLOCKS["control_block"].instantiate()
	b.block_formats = ["while {bool: BOOL}"]
	b.statements = ["while {bool}:"]
	control_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Break"
	b.statement = "break"
	control_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Continue"
	b.statement = "continue"
	control_list.append(b)

	var control_category: BlockCategory = BlockCategory.new("Control", control_list, Color("ffad76"))

	# Test
	var test_list: Array[Block] = []

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "print {text: STRING}"
	b.statement = "print({text})"
	test_list.append(b)

	b = BLOCKS["entry_block"].instantiate()
	b.block_format = "On body enter [body: NODE_PATH]"
	b.statement = "func _on_body_enter(body):"
	test_list.append(b)

	var test_category: BlockCategory = BlockCategory.new("Test", test_list, Color("9989df"))

	# Signal
	var signal_list: Array[Block] = []

	b = BLOCKS["entry_block"].instantiate()
	# HACK: make signals work with new entry nodes. NIL instead of STRING type allows
	# plain text input for function name. Should revamp signals later
	b.block_format = "On signal {signal: NIL}"
	b.statement = "func signal_{signal}():"
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
	b.block_format = "Add {node: NODE_PATH} to group {group: STRING}"
	b.statement = "get_node({node}).add_to_group({group})"
	signal_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Remove from group {group: STRING}"
	b.statement = "remove_from_group({group})"
	signal_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Remove {node: NODE_PATH} from group {group: STRING}"
	b.statement = "get_node({node}).remove_from_group({group})"
	signal_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_BOOL
	b.block_format = "Is in group {group: STRING}"
	b.statement = "is_in_group({group})"
	signal_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_BOOL
	b.block_format = "Is {node: NODE_PATH} in group {group: STRING}"
	b.statement = "get_node({node}).is_in_group({group})"
	signal_list.append(b)

	var signal_category: BlockCategory = BlockCategory.new("Signal", signal_list, Color("f0c300"))

	# Variable
	var variable_list: Array[Block] = []

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Set String {var: STRING} {value: STRING}"
	b.statement = "VAR_DICT[{var}] = {value}"
	variable_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.block_format = "Get String {var: STRING}"
	b.statement = "VAR_DICT[{var}]"
	variable_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Set Int {var: STRING} {value: INT}"
	b.statement = "VAR_DICT[{var}] = {value}"
	variable_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_INT
	b.block_format = "Get Int {var: STRING}"
	b.statement = "VAR_DICT[{var}]"
	variable_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.block_format = "To String {int: INT}"
	b.statement = "str({int})"
	variable_list.append(b)

	var variable_category: BlockCategory = BlockCategory.new("Variables", variable_list, Color("4f975d"))

	# Math
	var math_list: Array[Block] = []

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_INT
	b.block_format = "{a: INT} + {b: INT}"
	b.statement = "({a} + {b})"
	math_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_INT
	b.block_format = "{a: INT} - {b: INT}"
	b.statement = "({a} - {b})"
	math_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_INT
	b.block_format = "{a: INT} * {b: INT}"
	b.statement = "({a} * {b})"
	math_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_INT
	b.block_format = "{a: INT} / {b: INT}"
	b.statement = "({a} / {b})"
	math_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_INT
	b.block_format = "{base: INT} ^ {exp: INT}"
	b.statement = "(pow({base}, {exp}))"
	math_list.append(b)

	var math_category: BlockCategory = BlockCategory.new("Math", math_list, Color("3042c5"))

	# Logic

	var logic_list: Array[Block] = []

	for op in ["==", ">", "<", ">=", "<=", "!="]:
		b = BLOCKS["parameter_block"].instantiate()
		b.variant_type = TYPE_BOOL
		b.block_format = "{int1: INT} %s {int2: INT}" % op
		b.statement = "({int1} %s {int2})" % op
		logic_list.append(b)

	for op in ["and", "or"]:
		b = BLOCKS["parameter_block"].instantiate()
		b.variant_type = TYPE_BOOL
		b.block_format = "{bool1: BOOL} %s {bool2: BOOL}" % op
		b.statement = "({bool1} %s {bool2})" % op
		logic_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_BOOL
	b.block_format = "Not {bool: BOOL}"
	b.statement = "(!{bool})"
	logic_list.append(b)

	var logic_category: BlockCategory = BlockCategory.new("Logic", logic_list, Color("42b8e3"))

	# Input
	var input_list: Array[Block] = _get_input_blocks()
	var input_category: BlockCategory = BlockCategory.new("Input", input_list, Color.SLATE_GRAY)

	# Sound
	var sound_list: Array[Block] = []

	b = BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Load file {file_path: STRING} as sound {name: STRING}"
	b.statement = "var sound = AudioStreamPlayer.new()\nsound.name = {name}\nsound.set_stream(load({file_path}))\nadd_child(sound)\nsound.set_owner(self)"
	sound_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Play the sound {name: STRING} with Volume dB {db: FLOAT} and Pitch Scale {pitch: FLOAT}"
	b.statement = "var sound = find_child({name})\nsound.volume_db = {db}\nsound.pitch_scale = {pitch}\nsound.play()"
	sound_list.append(b)

	var sound_category: BlockCategory = BlockCategory.new("Sound", sound_list, Color("e30fc0"))

	return [
		lifecycle_category,
		signal_category,
		control_category,
		test_category,
		math_category,
		logic_category,
		variable_category,
		input_category,
		sound_category,
	]


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


static func property_to_blocklist(property: Dictionary) -> Array[Block]:
	var block_list: Array[Block] = []

	var block_type = property.type

	if block_type:
		var type_string: String = Types.VARIANT_TYPE_TO_STRING[block_type]

		var b = BLOCKS["statement_block"].instantiate()
		b.block_format = "Set %s to {value: %s}" % [property.name.capitalize(), type_string]
		b.statement = "%s = {value}" % property.name
		block_list.append(b)

		b = BLOCKS["statement_block"].instantiate()
		b.block_format = "Change %s by {value: %s}" % [property.name.capitalize(), type_string]
		b.statement = "%s += {value}" % property.name
		block_list.append(b)

		b = BLOCKS["parameter_block"].instantiate()
		b.block_type = block_type
		b.block_format = "%s" % property.name.capitalize()
		b.statement = "%s" % property.name
		block_list.append(b)

	return block_list


static func category_from_property_list(property_list: Array, selected_props: Array, p_name: String, p_color: Color) -> BlockCategory:
	var block_list: Array[Block]

	for selected_property in selected_props:
		var found_prop
		for prop in property_list:
			if selected_property == prop.name:
				found_prop = prop
				break
		block_list.append_array(property_to_blocklist(found_prop))

	return BlockCategory.new(p_name, block_list, p_color)


static func get_inherited_categories(_class_name: String) -> Array[BlockCategory]:
	var cats: Array[BlockCategory] = []

	var current: String = _class_name

	while current != "":
		add_to_categories(cats, get_built_in_categories(current))
		current = ClassDB.get_parent_class(current)

	return cats


static func get_built_in_categories(_class_name: String) -> Array[BlockCategory]:
	var cats: Array[BlockCategory] = []

	var props: Array = []
	var block_list: Array[Block] = []

	match _class_name:
		"Node2D":
			var b = BLOCKS["statement_block"].instantiate()
			b.block_format = "Set Rotation Degrees {angle: FLOAT}"
			b.statement = "rotation_degrees = {angle}"
			block_list.append(b)

			props = ["position", "rotation", "scale"]

		"CanvasItem":
			props = ["modulate"]

		"RigidBody2D":
			# On body entered

			props = ["mass", "linear_velocity", "angular_velocity"]

	var prop_list = ClassDB.class_get_property_list(_class_name, true)

	var class_cat: BlockCategory = category_from_property_list(prop_list, props, _class_name, Color.SLATE_GRAY)
	block_list.append_array(class_cat.block_list)
	class_cat.block_list = block_list
	if props.size() > 0:
		cats.append(class_cat)

	return cats


static func _get_input_blocks() -> Array[Block]:
	var block_list: Array[Block]

	InputMap.load_from_project_settings()

	for action: StringName in InputMap.get_actions():
		var block: Block = BLOCKS["parameter_block"].instantiate()
		block.variant_type = TYPE_BOOL
		block.block_format = "Is action %s pressed" % action
		block.statement = 'Input.is_action_pressed("%s")' % action
		block_list.append(block)

		block = BLOCKS["parameter_block"].instantiate()
		block.variant_type = TYPE_BOOL
		block.block_format = "Is action %s just pressed" % action
		block.statement = 'Input.is_action_just_pressed("%s")' % action
		block_list.append(block)

		block = BLOCKS["parameter_block"].instantiate()
		block.variant_type = TYPE_BOOL
		block.block_format = "Is action %s just released" % action
		block.statement = 'Input.is_action_just_released("%s")' % action
		block_list.append(block)

	return block_list
