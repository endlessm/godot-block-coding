class_name CategoryFactory
extends Object

const BLOCKS: Dictionary = {
	"control_block": preload("res://addons/block_code/ui/blocks/control_block/control_block.tscn"),
	"parameter_block": preload("res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn"),
	"statement_block": preload("res://addons/block_code/ui/blocks/statement_block/statement_block.tscn"),
	"entry_block": preload("res://addons/block_code/ui/blocks/entry_block/entry_block.tscn"),
}

## Properties for builtin categories. Order starts at 10 for the first
## category and then are separated by 10 to allow custom categories to
## be easily placed between builtin categories.
const BUILTIN_PROPS: Dictionary = {
	"Lifecycle":
	{
		"color": Color("ec3b59"),
		"order": 10,
	},
	"Transform | Position":
	{
		"color": Color("4b6584"),
		"order": 20,
	},
	"Transform | Rotation":
	{
		"color": Color("4b6584"),
		"order": 30,
	},
	"Transform | Scale":
	{
		"color": Color("4b6584"),
		"order": 40,
	},
	"Graphics | Modulate":
	{
		"color": Color("03aa74"),
		"order": 50,
	},
	"Graphics | Visibility":
	{
		"color": Color("03aa74"),
		"order": 60,
	},
	"Graphics | Viewport":
	{
		"color": Color("03aa74"),
		"order": 61,
	},
	"Sounds":
	{
		"color": Color("e30fc0"),
		"order": 70,
	},
	"Physics | Mass":
	{
		"color": Color("a5b1c2"),
		"order": 80,
	},
	"Physics | Velocity":
	{
		"color": Color("a5b1c2"),
		"order": 90,
	},
	"Input":
	{
		"color": Color("d54322"),
		"order": 100,
	},
	"Communication | Methods":
	{
		"color": Color("4b7bec"),
		"order": 110,
	},
	"Communication | Groups":
	{
		"color": Color("4b7bec"),
		"order": 120,
	},
	"Info | Score":
	{
		"color": Color("cf6a87"),
		"order": 130,
	},
	"Loops":
	{
		"color": Color("20bf6b"),
		"order": 140,
	},
	"Logic | Conditionals":
	{
		"color": Color("45aaf2"),
		"order": 150,
	},
	"Logic | Comparison":
	{
		"color": Color("45aaf2"),
		"order": 160,
	},
	"Logic | Boolean":
	{
		"color": Color("45aaf2"),
		"order": 170,
	},
	"Variables":
	{
		"color": Color("ff8f08"),
		"order": 180,
	},
	"Math":
	{
		"color": Color("a55eea"),
		"order": 190,
	},
	"Log":
	{
		"color": Color("002050"),
		"order": 200,
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
	# Accessing a static Callable from a static function fails in 4.2.1.
	# Use the fully qualified name.
	# https://github.com/godotengine/godot/issues/86032
	cats.sort_custom(CategoryFactory._category_cmp)
	return cats


static func get_general_blocks() -> Array[Block]:
	var b: Block
	var block_list: Array[Block] = []

#region Lifecycle

	b = BLOCKS["entry_block"].instantiate()
	b.block_name = "ready_block"
	b.block_format = "On Ready"
	b.statement = "func _ready():"
	b.tooltip_text = 'The following will be executed when the node is "ready"'
	b.category = "Lifecycle"
	block_list.append(b)

	b = BLOCKS["entry_block"].instantiate()
	b.block_name = "process_block"
	b.block_format = "On Process"
	b.statement = "func _process(delta):"
	b.tooltip_text = "The following will be executed during the processing step of the main loop"
	b.category = "Lifecycle"
	block_list.append(b)

	b = BLOCKS["entry_block"].instantiate()
	b.block_name = "physics_process_block"
	b.block_format = "On Physics Process"
	b.statement = "func _physics_process(delta):"
	b.tooltip_text = 'The following will be executed during the "physics" processing step of the main loop'
	b.category = "Lifecycle"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Queue Free"
	b.statement = "queue_free()"
	b.tooltip_text = "Queues this node to be deleted at the end of the current frame"
	b.category = "Lifecycle"
	block_list.append(b)

#endregion
#region Loops

	b = BLOCKS["control_block"].instantiate()
	b.block_formats = ["repeat {number: INT}"]
	b.statements = ["for i in {number}:"]
	b.category = "Loops"
	block_list.append(b)

	b = BLOCKS["control_block"].instantiate()
	b.block_formats = ["while {condition: BOOL}"]
	b.statements = ["while {condition}:"]
	b.category = "Loops"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Await scene ready"
	b.statement = (
		"""
		if not get_tree().root.is_node_ready():
			await get_tree().root.ready
		"""
		. dedent()
	)
	b.category = "Loops"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Break"
	b.statement = "break"
	b.category = "Loops"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Continue"
	b.statement = "continue"
	b.category = "Loops"
	block_list.append(b)

#endregion
#region Logs

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "print {text: STRING}"
	b.statement = "print({text})"
	b.defaults = {"text": "Hello"}
	b.tooltip_text = "Print the text to output"
	b.category = "Log"
	block_list.append(b)

#endregion
#region Communication

	b = BLOCKS["entry_block"].instantiate()
	# HACK: make signals work with new entry nodes. NIL instead of STRING type allows
	# plain text input for function name. Should revamp signals later
	b.block_format = "Define method {method_name: NIL}"
	b.statement = "func {method_name}():"
	b.category = "Communication | Methods"
	b.tooltip_text = "Define a method/function with following statements"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Call method {method_name: STRING} in group {group: STRING}"
	b.statement = "get_tree().call_group({group}, {method_name})"
	b.category = "Communication | Methods"
	b.tooltip_text = "Calls the method/function on each member of the given group"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Call method {method_name: STRING} in node {node_path: NODE_PATH}"
	b.statement = (
		"""
		var node = get_node({node_path})
		if node:
			node.call({method_name})
		"""
		. dedent()
	)
	b.tooltip_text = "Calls the method/function of the given node"
	b.category = "Communication | Methods"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Add to group {group: STRING}"
	b.statement = "add_to_group({group})"
	b.category = "Communication | Groups"
	b.tooltip_text = "Add this node into the group"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Add {node: NODE_PATH} to group {group: STRING}"
	b.statement = "get_node({node}).add_to_group({group})"
	b.category = "Communication | Groups"
	b.tooltip_text = "Add the node into the group"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Remove from group {group: STRING}"
	b.statement = "remove_from_group({group})"
	b.tooltip_text = "Remove this node from the group"
	b.category = "Communication | Groups"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_format = "Remove {node: NODE_PATH} from group {group: STRING}"
	b.statement = "get_node({node}).remove_from_group({group})"
	b.tooltip_text = "Remove the node from the group"
	b.category = "Communication | Groups"
	block_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_BOOL
	b.block_format = "Is in group {group: STRING}"
	b.statement = "is_in_group({group})"
	b.tooltip_text = "Is this node in the group"
	b.category = "Communication | Groups"
	block_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_BOOL
	b.block_format = "Is {node: NODE_PATH} in group {group: STRING}"
	b.statement = "get_node({node}).is_in_group({group})"
	b.tooltip_text = "Is the node in the group"
	b.category = "Communication | Groups"
	block_list.append(b)

#endregion
#region Variables

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

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_VECTOR2
	b.block_format = "Vector2 x: {x: FLOAT} y: {y: FLOAT}"
	b.statement = "Vector2({x}, {y})"
	b.category = "Variables"
	block_list.append(b)

#endregion
#region Math

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

#endregion
#region Logic

	b = BLOCKS["control_block"].instantiate()
	b.block_formats = ["if    {condition: BOOL}"]
	b.statements = ["if {condition}:"]
	b.category = "Logic | Conditionals"
	block_list.append(b)

	b = BLOCKS["control_block"].instantiate()
	b.block_formats = ["if    {condition: BOOL}", "else"]
	b.statements = ["if {condition}:", "else:"]
	b.category = "Logic | Conditionals"
	block_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_BOOL
	b.block_format = "{int1: INT} {op: OPTION} {int2: INT}"
	b.statement = "({int1} {op} {int2})"
	b.defaults = {"op": OptionData.new(["==", ">", "<", ">=", "<=", "!="])}
	b.category = "Logic | Comparison"
	block_list.append(b)

	for op in ["and", "or"]:
		b = BLOCKS["parameter_block"].instantiate()
		b.variant_type = TYPE_BOOL
		b.block_format = "{bool1: BOOL} %s {bool2: BOOL}" % op
		b.statement = "({bool1} %s {bool2})" % op
		b.category = "Logic | Boolean"
		block_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_BOOL
	b.block_format = "Not {bool: BOOL}"
	b.statement = "(not {bool})"
	b.category = "Logic | Boolean"
	block_list.append(b)

#endregion
#region Input

	block_list.append_array(_get_input_blocks())

#endregion
#region Sounds
	b = BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Load file {file_path: STRING} as sound {name: STRING}"
	b.statement = (
		"""
		VAR_DICT[{name}] = AudioStreamPlayer.new()
		VAR_DICT[{name}].name = {name}
		VAR_DICT[{name}].set_stream(load({file_path}))
		add_child(VAR_DICT[{name}])
		"""
		. dedent()
	)
	b.tooltip_text = "Load a resource file as the audio stream"
	b.category = "Sounds"
	block_list.append(b)

	b = BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Play the sound {name: STRING} with Volume dB {db: FLOAT} and Pitch Scale {pitch: FLOAT}"
	b.statement = (
		"""
		VAR_DICT[{name}].volume_db = {db}
		VAR_DICT[{name}].pitch_scale = {pitch}
		VAR_DICT[{name}].play()
		"""
		. dedent()
	)
	b.defaults = {"db": "0.0", "pitch": "1.0"}
	b.tooltip_text = "Play the audio stream with volume and pitch"
	b.category = "Sounds"
	block_list.append(b)
#endregion
#region Graphics

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_FLOAT
	b.block_format = "Viewport Width"
	b.statement = "(func (): var transform: Transform2D = get_viewport_transform(); var scale: Vector2 = transform.get_scale(); return -transform.origin.x / scale.x + get_viewport_rect().size.x / scale.x).call()"
	b.category = "Graphics | Viewport"
	block_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_FLOAT
	b.block_format = "Viewport Height"
	b.statement = "(func (): var transform: Transform2D = get_viewport_transform(); var scale: Vector2 = transform.get_scale(); return -transform.origin.y / scale.y + get_viewport_rect().size.y / scale.y).call()"
	b.category = "Graphics | Viewport"
	block_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	b.variant_type = TYPE_VECTOR2
	b.block_format = "Viewport Center"
	b.statement = "(func (): var transform: Transform2D = get_viewport_transform(); var scale: Vector2 = transform.get_scale(); return -transform.origin / scale + get_viewport_rect().size / scale / 2).call()"
	b.category = "Graphics | Viewport"
	block_list.append(b)

#endregion

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
			b.category = "Transform | Rotation"
			block_list.append(b)

			props = {
				"position": "Transform | Position",
				"rotation": "Transform | Rotation",
				"scale": "Transform | Scale",
			}

		"CanvasItem":
			props = {
				"modulate": "Graphics | Modulate",
				"visible": "Graphics | Visibility",
			}

		"RigidBody2D":
			for verb in ["entered", "exited"]:
				var b = BLOCKS["entry_block"].instantiate()
				b.block_format = "On [body: NODE_PATH] %s" % [verb]
				# HACK: Blocks refer to nodes by path but the callback receives the node itself;
				# convert to path
				b.statement = (
					(
						"""
						func _on_body_%s(_body: Node):
							var body: NodePath = _body.get_path()
						"""
						. dedent()
					)
					% [verb]
				)
				b.signal_name = "body_%s" % [verb]
				b.category = "Communication | Methods"
				block_list.append(b)

			var b = BLOCKS["statement_block"].instantiate()
			b.block_format = "Set Physics Position {position: VECTOR2}"
			b.statement = (
				"""
				PhysicsServer2D.body_set_state(
					get_rid(),
					PhysicsServer2D.BODY_STATE_TRANSFORM,
					Transform2D.IDENTITY.translated({position})
				)
				"""
				. dedent()
			)
			b.category = "Transform | Position"
			block_list.append(b)

			props = {
				"mass": "Physics | Mass",
				"linear_velocity": "Physics | Velocity",
				"angular_velocity": "Physics | Velocity",
			}

		"Area2D":
			for verb in ["entered", "exited"]:
				var b = BLOCKS["entry_block"].instantiate()
				b.block_format = "On [body: NODE_PATH] %s" % [verb]
				# HACK: Blocks refer to nodes by path but the callback receives the node itself;
				# convert to path
				b.statement = (
					(
						"""
						func _on_body_%s(_body: Node2D):
							var body: NodePath = _body.get_path()
						"""
						. dedent()
					)
					% [verb]
				)
				b.signal_name = "body_%s" % [verb]
				b.category = "Communication | Methods"
				block_list.append(b)

		"CharacterBody2D":
			var b = BLOCKS["statement_block"].instantiate()
			b.block_type = Types.BlockType.EXECUTE
			b.block_format = "Move with keys {up: STRING} {down: STRING} {left: STRING} {right: STRING} with speed {speed: VECTOR2}"
			b.statement = (
				"var dir = Vector2()\n"
				+ "dir.x += float(Input.is_key_pressed(OS.find_keycode_from_string({right})))\n"
				+ "dir.x -= float(Input.is_key_pressed(OS.find_keycode_from_string({left})))\n"
				+ "dir.y += float(Input.is_key_pressed(OS.find_keycode_from_string({down})))\n"
				+ "dir.y -= float(Input.is_key_pressed(OS.find_keycode_from_string({up})))\n"
				+ "dir = dir.normalized()\n"
				+ "velocity = dir*{speed}\n"
				+ "move_and_slide()"
			)
			b.defaults = {
				"up": "W",
				"down": "S",
				"left": "A",
				"right": "D",
			}
			b.category = "Input"
			block_list.append(b)

			b = BLOCKS["statement_block"].instantiate()
			b.block_type = Types.BlockType.EXECUTE
			b.block_format = "Move and slide"
			b.statement = "move_and_slide()"
			b.category = "Physics | Velocity"
			block_list.append(b)

			props = {
				"velocity": "Physics | Velocity",
			}

	var prop_list = ClassDB.class_get_property_list(_class_name, true)
	block_list.append_array(blocks_from_property_list(prop_list, props))

	return block_list


static func _get_input_blocks() -> Array[Block]:
	var block_list: Array[Block]

	var editor_input_actions: Dictionary = {}
	var editor_input_action_deadzones: Dictionary = {}
	if Engine.is_editor_hint():
		var actions := InputMap.get_actions()
		for action in actions:
			if action.begins_with("spatial_editor"):
				var events := InputMap.action_get_events(action)
				editor_input_actions[action] = events
				editor_input_action_deadzones[action] = InputMap.action_get_deadzone(action)

	InputMap.load_from_project_settings()

	var block: Block = BLOCKS["parameter_block"].instantiate()
	block.variant_type = TYPE_BOOL
	block.block_format = "Is action {action_name: OPTION} {action: OPTION}"
	block.statement = 'Input.is_action_{action}("{action_name}")'
	block.defaults = {"action_name": OptionData.new(InputMap.get_actions()), "action": OptionData.new(["pressed", "just_pressed", "just_released"])}
	block.category = "Input"
	block_list.append(block)

	if Engine.is_editor_hint():
		for action in editor_input_actions.keys():
			InputMap.add_action(action, editor_input_action_deadzones[action])
			for event in editor_input_actions[action]:
				InputMap.action_add_event(action, event)

	return block_list
