class_name CategoryFactory
extends Object

const BLOCKS: Dictionary = {
	"basic_block": preload("res://addons/block_code/ui/blocks/basic_block/basic_block.tscn"),
	"control_block": preload("res://addons/block_code/ui/blocks/control_block/control_block.tscn"),
	"parameter_block": preload("res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn"),
	"statement_block": preload("res://addons/block_code/ui/blocks/statement_block/statement_block.tscn"),
	"entry_block": preload("res://addons/block_code/ui/blocks/entry_block/entry_block.tscn"),
}

## Properties for builtin categories. Order starts at 10 for the first
## category and then are separated by 10 to allow custom categories to
## be easily placed between builtin categories.
const BUILTIN_PROPS: Dictionary = {
	"Control":
	{
		"color": Color("ffad76"),
		"order": 30,
	},
	"Graphics":
	{
		"color": Color("9be371"),
		"order": 110,
	},
	"Input":
	{
		"color": Color.SLATE_GRAY,
		"order": 70,
	},
	"Lifecycle":
	{
		"color": Color("fa5956"),
		"order": 10,
	},
	"Logic":
	{
		"color": Color("42b8e3"),
		"order": 60,
	},
	"Math":
	{
		"color": Color("3042c5"),
		"order": 50,
	},
	"Movement":
	{
		"color": Color("e2e72b"),
		"order": 90,
	},
	"Signal":
	{
		"color": Color("f0c300"),
		"order": 20,
	},
	"Sound":
	{
		"color": Color("e30fc0"),
		"order": 80,
	},
	"Size":
	{
		"color": Color("f79511"),
		"order": 100,
	},
	"Test":
	{
		"color": Color("9989df"),
		"order": 40,
	},
	"Variables":
	{
		"color": Color("4f975d"),
		"order": 60,
	},
}


## Compare block categories for sorting. Compare by order then name.
static func _category_cmp(a: BlockCategory, b: BlockCategory) -> bool:
	if a.order != b.order:
		return a.order < b.order
	return a.name.naturalcasecmp_to(b.name) < 0


static func get_categories(blocks: Array[Block], extra_categories: Array[BlockCategory] = []) -> Array[BlockCategory]:
	var cat_map: Dictionary = {}
	var extra_cat_map: Dictionary = {}

	for cat in extra_categories:
		extra_cat_map[cat.name] = cat

	for block in blocks:
		var cat: BlockCategory = cat_map.get(block.category)
		if cat == null:
			cat = extra_cat_map.get(block.category)
			if cat == null:
				var props: Dictionary = BUILTIN_PROPS.get(block.category, {})
				var color: Color = props.get("color", Color.SLATE_GRAY)
				var order: int = props.get("order", 0)
				cat = BlockCategory.new(block.category, color, order)
			cat_map[block.category] = cat
		cat.block_list.append(block)

	# Dictionary.values() returns an untyped Array and there's no way to
	# convert an array type besides Array.assign().
	var cats: Array[BlockCategory] = []
	cats.assign(cat_map.values())
	cats.sort_custom(_category_cmp)
	return cats


static func get_general_blocks() -> Array[Block]:
	var b: Block
	var block_list: Array[Block] = []

	# Lifecycle
	b = BLOCKS["entry_block"].instantiate()
	b.block_name = "ready_block"
	b.block_format = "On Ready"
	b.statement = "func _ready():"
	b.category = "Lifecycle"
	block_list.append(b)

	b = BLOCKS["entry_block"].instantiate()
	b.block_name = "process_block"
	b.block_format = "On Process"
	b.statement = "func _process(delta):"
	b.category = "Lifecycle"
	block_list.append(b)

	b = BLOCKS["entry_block"].instantiate()
	b.block_name = "physics_process_block"
	b.block_format = "On Physics Process"
	b.statement = "func _physics_process(delta):"
	b.category = "Lifecycle"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Queue Free"
	b.statement = "queue_free()"
	b.category = "Lifecycle"
	block_list.append(b)

	# Control
	b = BLOCKS["control_block"].instantiate()
	b.block_formats = ["if    {condition: BOOL}"]
	b.statements = ["if {condition}:"]
	b.category = "Control"
	block_list.append(b)

	b = BLOCKS["control_block"].instantiate()
	b.block_formats = ["if    {condition: BOOL}", "else"]
	b.statements = ["if {condition}:", "else:"]
	b.category = "Control"
	block_list.append(b)

	b = BLOCKS["control_block"].instantiate()
	b.block_formats = ["repeat {number: INT}"]
	b.statements = ["for i in {number}:"]
	b.category = "Control"
	block_list.append(b)

	b = BLOCKS["control_block"].instantiate()
	b.block_formats = ["while {condition: BOOL}"]
	b.statements = ["while {condition}:"]
	b.category = "Control"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Break"
	b.statement = "break"
	b.category = "Control"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Continue"
	b.statement = "continue"
	b.category = "Control"
	block_list.append(b)

	# Test
	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "print {text: STRING}"
	b.statement = "print({text})"
	b.defaults = {"text": "Hello"}
	b.category = "Test"
	block_list.append(b)

	# Signal
	b = BLOCKS["entry_block"].instantiate()
	# HACK: make signals work with new entry nodes. NIL instead of STRING type allows
	# plain text input for function name. Should revamp signals later
	b.block_format = "On signal {signal: NIL}"
	b.statement = "func signal_{signal}():"
	b.category = "Signal"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Send signal {signal: STRING} to group {group: STRING}"
	b.statement = 'if get_tree().root.has_node("SignalManager"):\n' + '\tget_tree().root.get_node_or_null("SignalManager").broadcast_signal({group}, {signal})'
	b.category = "Signal"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Send signal {signal: STRING} to node {node: NODE_PATH}"
	b.statement = 'if get_tree().root.has_node("SignalManager"):\n' + '\tget_tree().root.get_node_or_null("SignalManager").send_signal_to_node({node}, {signal})'
	b.category = "Signal"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Add to group {group: STRING}"
	b.statement = "add_to_group({group})"
	b.category = "Signal"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Add {node: NODE_PATH} to group {group: STRING}"
	b.statement = "get_node({node}).add_to_group({group})"
	b.category = "Signal"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Remove from group {group: STRING}"
	b.statement = "remove_from_group({group})"
	b.category = "Signal"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Remove {node: NODE_PATH} from group {group: STRING}"
	b.statement = "get_node({node}).remove_from_group({group})"
	b.category = "Signal"
	block_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_BOOL
	b.block_format = "Is in group {group: STRING}"
	b.statement = "is_in_group({group})"
	b.category = "Signal"
	block_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_BOOL
	b.block_format = "Is {node: NODE_PATH} in group {group: STRING}"
	b.statement = "get_node({node}).is_in_group({group})"
	b.category = "Signal"
	block_list.append(b)

	# Variables
	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Set String {var: STRING} {value: STRING}"
	b.statement = "VAR_DICT[{var}] = {value}"
	b.category = "Variables"
	block_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.block_format = "Get String {var: STRING}"
	b.statement = "VAR_DICT[{var}]"
	b.category = "Variables"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Set Int {var: STRING} {value: INT}"
	b.statement = "VAR_DICT[{var}] = {value}"
	b.category = "Variables"
	block_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_INT
	b.block_format = "Get Int {var: STRING}"
	b.statement = "VAR_DICT[{var}]"
	b.category = "Variables"
	block_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.block_format = "To String {int: INT}"
	b.statement = "str({int})"
	b.category = "Variables"
	block_list.append(b)

	# Math
	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_INT
	b.block_format = "{a: INT} + {b: INT}"
	b.statement = "({a} + {b})"
	b.category = "Math"
	block_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_INT
	b.block_format = "{a: INT} - {b: INT}"
	b.statement = "({a} - {b})"
	b.category = "Math"
	block_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_INT
	b.block_format = "{a: INT} * {b: INT}"
	b.statement = "({a} * {b})"
	b.category = "Math"
	block_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_INT
	b.block_format = "{a: INT} / {b: INT}"
	b.statement = "({a} / {b})"
	b.category = "Math"
	block_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_INT
	b.block_format = "{base: INT} ^ {exp: INT}"
	b.statement = "(pow({base}, {exp}))"
	b.category = "Math"
	block_list.append(b)

	# Logic
	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_BOOL
	b.block_format = "{int1: INT} {op: OPTION} {int2: INT}"
	b.statement = "({int1} {op} {int2})"
	b.defaults = {"op": OptionData.new(["==", ">", "<", ">=", "<=", "!="])}
	b.category = "Logic"
	block_list.append(b)

	for op in ["and", "or"]:
		b = BLOCKS["parameter_block"].instantiate()
		b.variant_type = TYPE_BOOL
		b.block_format = "{bool1: BOOL} %s {bool2: BOOL}" % op
		b.statement = "({bool1} %s {bool2})" % op
		b.category = "Logic"
		block_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_BOOL
	b.block_format = "Not {bool: BOOL}"
	b.statement = "(not {bool})"
	b.category = "Logic"
	block_list.append(b)

	# Input
	block_list.append_array(_get_input_blocks())

	# Sound
	b = BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Load file {file_path: STRING} as sound {name: STRING}"
	b.statement = "VAR_DICT[{name}] = AudioStreamPlayer.new()\nVAR_DICT[{name}].name = {name}\nVAR_DICT[{name}].set_stream(load({file_path}))\nadd_child(VAR_DICT[{name}])"
	b.category = "Sound"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Play the sound {name: STRING} with Volume dB {db: FLOAT} and Pitch Scale {pitch: FLOAT}"
	b.statement = "VAR_DICT[{name}].volume_db = {db}\nVAR_DICT[{name}].pitch_scale = {pitch}\nVAR_DICT[{name}].play()"
	b.defaults = {"db": "0.0", "pitch": "1.0"}
	b.category = "Sound"
	block_list.append(b)

	return block_list


static func property_to_blocklist(property: Dictionary) -> Array[Block]:
	var block_list: Array[Block] = []

	var block_type = property.type

	if block_type:
		var type_string: String = Types.VARIANT_TYPE_TO_STRING[block_type]

		var b = BLOCKS["statement_block"].instantiate()
		b.block_format = "Set %s to {value: %s}" % [property.name.capitalize(), type_string]
		b.statement = "%s = {value}" % property.name
		b.category = property.category
		block_list.append(b)

		b = BLOCKS["statement_block"].instantiate()
		b.block_format = "Change %s by {value: %s}" % [property.name.capitalize(), type_string]
		b.statement = "%s += {value}" % property.name
		b.category = property.category
		block_list.append(b)

		b = BLOCKS["parameter_block"].instantiate()
		b.block_type = block_type
		b.block_format = "%s" % property.name.capitalize()
		b.statement = "%s" % property.name
		b.category = property.category
		block_list.append(b)

	return block_list


static func blocks_from_property_list(property_list: Array, selected_props: Dictionary) -> Array[Block]:
	var block_list: Array[Block]

	for selected_property in selected_props:
		var found_prop
		for prop in property_list:
			if selected_property == prop.name:
				found_prop = prop
				found_prop.category = selected_props[selected_property]
				break
		if found_prop:
			block_list.append_array(property_to_blocklist(found_prop))
		else:
			push_warning("No property matching %s found in %s" % [selected_property, property_list])

	return block_list


static func get_inherited_blocks(_class_name: String) -> Array[Block]:
	var blocks: Array[Block] = []

	var current: String = _class_name

	while current != "":
		blocks.append_array(get_built_in_blocks(current))
		current = ClassDB.get_parent_class(current)

	return blocks


static func get_built_in_blocks(_class_name: String) -> Array[Block]:
	var props: Dictionary = {}
	var block_list: Array[Block] = []

	match _class_name:
		"Node2D":
			var b = BLOCKS["statement_block"].instantiate()
			b.block_format = "Set Rotation Degrees {angle: FLOAT}"
			b.statement = "rotation_degrees = {angle}"
			b.category = "Movement"
			block_list.append(b)

			props = {
				"position": "Movement",
				"rotation": "Movement",
				"scale": "Size",
			}

		"CanvasItem":
			props = {
				"modulate": "Graphics",
				"visible": "Graphics",
			}

		"RigidBody2D":
			for verb in ["entered", "exited"]:
				var b = BLOCKS["entry_block"].instantiate()
				b.block_format = "On [body: NODE_PATH] %s" % [verb]
				# HACK: Blocks refer to nodes by path but the callback receives the node itself;
				# convert to path
				b.statement = "func _on_body_%s(_body: Node):\n\tvar body: NodePath = _body.get_path()" % [verb]
				b.signal_name = "body_%s" % [verb]
				b.category = "Signal"
				block_list.append(b)

			var b = BLOCKS["statement_block"].instantiate()
			b.block_format = "Set Physics Position {position: VECTOR2}"
			b.statement = "PhysicsServer2D.body_set_state(get_rid(),PhysicsServer2D.BODY_STATE_TRANSFORM,Transform2D.IDENTITY.translated({position}))"
			b.category = "Movement"
			block_list.append(b)

			props = {
				"mass": "Size",
				"linear_velocity": "Movement",
				"angular_velocity": "Movement",
			}

		"Area2D":
			for verb in ["entered", "exited"]:
				var b = BLOCKS["entry_block"].instantiate()
				b.block_format = "On [body: NODE_PATH] %s" % [verb]
				# HACK: Blocks refer to nodes by path but the callback receives the node itself;
				# convert to path
				b.statement = "func _on_body_%s(_body: Node2D):\n\tvar body: NodePath = _body.get_path()" % [verb]
				b.signal_name = "body_%s" % [verb]
				b.category = "Signal"
				block_list.append(b)

	var prop_list = ClassDB.class_get_property_list(_class_name, true)
	block_list.append_array(blocks_from_property_list(prop_list, props))

	return block_list


static func _get_input_blocks() -> Array[Block]:
	var block_list: Array[Block]

	InputMap.load_from_project_settings()

	var block: Block = BLOCKS["parameter_block"].instantiate()
	block.variant_type = TYPE_BOOL
	block.block_format = "Is action {action_name: OPTION} {action: OPTION}"
	block.statement = 'Input.is_action_{action}("{action_name}")'
	block.defaults = {"action_name": OptionData.new(InputMap.get_actions()), "action": OptionData.new(["pressed", "just_pressed", "just_released"])}
	block.category = "Input"
	block_list.append(block)

	return block_list
