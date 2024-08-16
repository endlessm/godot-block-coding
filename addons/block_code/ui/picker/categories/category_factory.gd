class_name CategoryFactory
extends Object

const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const Types = preload("res://addons/block_code/types/types.gd")
const Util = preload("res://addons/block_code/ui/util.gd")

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
	"Graphics | Animation":
	{
		"color": Color("03aa74"),
		"order": 62,
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

	# Lifecycle
	for block_name in [&"ready", &"process", &"physics_process", &"queue_free"]:
		b = Util.instantiate_block_by_name(block_name)
		block_list.append(b)

	# Loops
	for block_name in [&"for", &"while", &"break", &"continue", &"await_scene_ready"]:
		b = Util.instantiate_block_by_name(block_name)
		block_list.append(b)

	# Logs
	b = Util.instantiate_block_by_name(&"print")
	block_list.append(b)

	# Communication
	for block_name in [&"define_method", &"call_method_group", &"call_method_node"]:
		b = Util.instantiate_block_by_name(block_name)
		block_list.append(b)

	for block_name in [&"add_to_group", &"add_node_to_group", &"remove_from_group", &"remove_node_from_group", &"is_in_group", &"is_node_in_group"]:
		b = Util.instantiate_block_by_name(block_name)
		block_list.append(b)

	# Variables
	b = Util.instantiate_block_by_name(&"vector2")
	block_list.append(b)

	# Math
	for block_name in [&"add", &"subtract", &"multiply", &"divide", &"pow", &"randf_range", &"randi_range", &"sin", &"cos", &"tan"]:
		b = Util.instantiate_block_by_name(block_name)
		block_list.append(b)

	# Logic
	for block_name in [&"if", &"else_if", &"else", &"compare", &"and", &"or", &"not"]:
		b = Util.instantiate_block_by_name(block_name)
		block_list.append(b)

	# Input
	block_list.append_array(_get_input_blocks())

	# Sounds
	for block_name in [&"load_sound", &"play_sound", &"pause_continue_sound", &"stop_sound"]:
		b = Util.instantiate_block_by_name(block_name)
		block_list.append(b)

	# Graphics
	for block_name in [&"viewport_width", &"viewport_height", &"viewport_center"]:
		b = Util.instantiate_block_by_name(block_name)
		block_list.append(b)

	return block_list


static func property_to_blocklist(property: Dictionary) -> Array[Block]:
	var block_list: Array[Block] = []

	var variant_type = property.type

	const FALLBACK_SET_FOR_TYPE = {
		TYPE_BOOL: false,
		TYPE_INT: "0",
		TYPE_FLOAT: "0",
		TYPE_VECTOR2: "0,0",
		TYPE_COLOR: "DARK_ORANGE",
	}

	const FALLBACK_CHANGE_FOR_TYPE = {
		TYPE_BOOL: true,
		TYPE_INT: "1",
		TYPE_FLOAT: "1",
		TYPE_VECTOR2: "1,1",
		TYPE_COLOR: "DARK_ORANGE",
	}

	if variant_type:
		var type_string: String = Types.VARIANT_TYPE_TO_STRING[variant_type]

		var b = BLOCKS["statement_block"].instantiate()
		b.block_name = "set_prop_%s" % property.name
		b.block_format = "Set %s to {value: %s}" % [property.name.capitalize(), type_string]
		b.statement = "%s = {value}" % property.name
		var default_set = property.get("default_set", FALLBACK_SET_FOR_TYPE.get(variant_type, ""))
		b.defaults = {"value": default_set}
		b.category = property.category
		block_list.append(b)

		if property.get("has_change", true):
			b = BLOCKS["statement_block"].instantiate()
			b.block_name = "change_prop_%s" % property.name
			b.block_format = "Change %s by {value: %s}" % [property.name.capitalize(), type_string]
			b.statement = "%s += {value}" % property.name
			var default_change = property.get("default_change", FALLBACK_CHANGE_FOR_TYPE[variant_type])
			b.defaults = {"value": default_change}
			b.category = property.category
			block_list.append(b)

		b = BLOCKS["parameter_block"].instantiate()
		b.block_name = "get_prop_%s" % property.name
		b.variant_type = variant_type
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
				found_prop.merge(selected_props[selected_property])
				break
		if found_prop:
			block_list.append_array(property_to_blocklist(found_prop))
		else:
			push_warning("No property matching %s found in %s" % [selected_property, property_list])

	return block_list


static func get_inherited_blocks(_class_name: String) -> Array[Block]:
	var blocks: Array[Block] = []

	blocks.append_array(Util.instantiate_blocks_for_class(_class_name))

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
			props = {
				"position":
				{
					"category": "Transform | Position",
					"default_set": "100,100",
					"default_change": "1,1",
				},
				"rotation_degrees":
				{
					"category": "Transform | Rotation",
					"default_set": "45",
					"default_change": "1",
				},
				"scale":
				{
					"category": "Transform | Scale",
					"default_set": "2,2",
					"default_change": "0.1,0.1",
				},
			}

		"CanvasItem":
			props = {
				"modulate":
				{
					"category": "Graphics | Modulate",
					"has_change": false,
				},
				"visible":
				{
					"category": "Graphics | Visibility",
					"has_change": false,
				},
			}

		"RigidBody2D":
			for verb in ["entered", "exited"]:
				var b = BLOCKS["entry_block"].instantiate()
				b.block_name = "rigidbody2d_on_%s" % verb
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
			b.block_name = "rigidbody2d_physics_position"
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
				"mass": {"category": "Physics | Mass"},
				"linear_velocity": {"category": "Physics | Velocity"},
				"angular_velocity": {"category": "Physics | Velocity"},
			}

		"AudioStreamPlayer":
			props = {
				"stream_paused":
				{
					"category": "Sounds",
					"has_change": false,
				},
			}

		"CharacterBody2D":
			props = {
				"velocity": {"category": "Physics | Velocity"},
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
	block.block_name = "is_action"
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


static func get_variable_blocks(variables: Array[VariableResource]):
	var block_list: Array[Block]

	for variable in variables:
		var type_string: String = Types.VARIANT_TYPE_TO_STRING[variable.var_type]

		var b = BLOCKS["parameter_block"].instantiate()
		b.block_name = "get_var_%s" % variable.var_name
		b.variant_type = variable.var_type
		b.block_format = variable.var_name
		b.statement = variable.var_name
		# HACK: Color the blocks since they are outside of the normal picker system
		b.color = BUILTIN_PROPS["Variables"].color
		block_list.append(b)

		b = BLOCKS["statement_block"].instantiate()
		b.block_name = "set_var_%s" % variable.var_name
		b.block_type = Types.BlockType.STATEMENT
		b.block_format = "Set %s to {value: %s}" % [variable.var_name, type_string]
		b.statement = "%s = {value}" % [variable.var_name]
		b.color = BUILTIN_PROPS["Variables"].color
		block_list.append(b)

	return block_list
