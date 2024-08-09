class_name CategoryFactory
extends Object

const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const Types = preload("res://addons/block_code/types/types.gd")
const Util = preload("res://addons/block_code/ui/util.gd")
const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")

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

static var block_definition_dictionary: Dictionary


static func init_block_definition_dictionary():
	block_definition_dictionary = {}

	var path: String = "res://addons/block_code/blocks/"
	var files := get_files_in_dir_recursive(path, ".tres")

	for file in files:
		var block_definition = load(file)
		block_definition_dictionary[block_definition.name] = block_definition


static func get_files_in_dir_recursive(path: String, extension: String) -> Array:
	var files = []

	var dir := DirAccess.open(path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			var file_path = path + "/" + file_name
			if dir.current_is_dir():
				files.append_array(get_files_in_dir_recursive(file_path, extension))
			elif file_name.ends_with(extension):
				files.append(file_path)

			file_name = dir.get_next()

	return files


## Compare block categories for sorting. Compare by order then name.
static func _category_cmp(a: BlockCategory, b: BlockCategory) -> bool:
	if a.order != b.order:
		return a.order < b.order
	return a.name.naturalcasecmp_to(b.name) < 0


static func get_categories(blocks: Array[BlockDefinition], extra_categories: Array[BlockCategory] = []) -> Array[BlockCategory]:
	var category_map: Dictionary = {}
	var extra_category_map: Dictionary = {}

	for category in extra_categories:
		extra_category_map[category.name] = category

	for block in blocks:
		var block_category_name: String = block.category
		var category: BlockCategory = category_map.get(block_category_name)
		if category == null:
			category = extra_category_map.get(block_category_name)
			if category == null:
				var props: Dictionary = BUILTIN_PROPS.get(block_category_name, {})
				var color: Color = props.get("color", Color.SLATE_GRAY)
				var order: int = props.get("order", 0)
				category = BlockCategory.new(block_category_name, color, order)
			category_map[block_category_name] = category
		category.block_list.append(block)

	# Dictionary.values() returns an untyped Array and there's no way to
	# convert an array type besides Array.assign().
	var categories: Array[BlockCategory] = []
	categories.assign(category_map.values())

	# Accessing a static Callable from a static function fails in 4.2.1.
	# Use the fully qualified name.
	# https://github.com/godotengine/godot/issues/86032
	categories.sort_custom(CategoryFactory._category_cmp)

	return categories


static func get_block_definition_from_name(block_name: String) -> BlockDefinition:
	if not block_name in block_definition_dictionary:
		push_error("Cannot construct unknown block name.")
		return null

	return block_definition_dictionary[block_name]


static func construct_block_from_name(block_name: String):
	var block_definition: BlockDefinition = get_block_definition_from_name(block_name)
	return construct_block_from_definition(block_definition)


# Essentially: Create UI from block definition.
# Using current API but we can make a cleaner one
static func construct_block_from_definition(block_definition: BlockDefinition):
	if block_definition == null:
		push_error("Cannot construct block from null block definition.")
		return null

	var block: Block

	if block_definition.type == Types.BlockType.STATEMENT:
		block = BLOCKS["statement_block"].instantiate()
	elif block_definition.type == Types.BlockType.ENTRY:
		block = BLOCKS["entry_block"].instantiate()
	elif block_definition.type == Types.BlockType.VALUE:
		block = BLOCKS["parameter_block"].instantiate()
	elif block_definition.type == Types.BlockType.CONTROL:
		block = BLOCKS["control_block"].instantiate()
	else:
		push_error("Other block types not implemented yet.")
		return null

	block.definition = block_definition

	return block


static func construct_blocks_from_definition_list(block_definition_list: Array[BlockDefinition]) -> Array[Block]:
	var block_list: Array[Block]  # FIXME: Assign cast
	block_list.assign(block_definition_list.map(construct_block_from_definition))
	return block_list


static func get_general_blocks() -> Array[BlockDefinition]:
	var block_definition_list: Array[BlockDefinition]  # FIXME: Assign cast
	block_definition_list.assign(block_definition_dictionary.values())

#region Input
	block_definition_list.append_array(_get_input_blocks())
#endregion

	return block_definition_list


static func get_parameter_output_blocks(block_definition_list: Array[BlockDefinition]) -> Array[BlockDefinition]:
	var param_output_blocks: Array[BlockDefinition] = []

	for block_definition in block_definition_list:
		# Block must be entry to have parameter outputs (helps with performance of this method)
		if block_definition.type != Types.BlockType.ENTRY:
			continue

		var regex = RegEx.create_from_string("\\[([^\\]]+)\\]")  # Capture things of format [test]
		var results := regex.search_all(block_definition.display_template)

		for result in results:
			var param := result.get_string()
			param = param.substr(1, param.length() - 2)
			var split := param.split(": ")

			var param_name := split[0]
			var param_type_str := split[1]
			var param_type = Types.STRING_TO_VARIANT_TYPE[param_type_str]

			var bd = BlockDefinition.new()
			bd.name = block_definition.name + "_" + param_name
			bd.category = block_definition.category
			bd.type = Types.BlockType.VALUE
			bd.variant_type = param_type
			bd.display_template = param_name
			bd.code_template = param_name
			bd.scope = block_definition.code_template

			param_output_blocks.append(bd)

	return param_output_blocks


static func property_to_blocklist(property: Dictionary) -> Array[BlockDefinition]:
	var block_definition_list: Array[BlockDefinition] = []

	var variant_type = property.type

	const FALLBACK_SET_FOR_TYPE = {
		TYPE_INT: 0,
		TYPE_FLOAT: 0.0,
		TYPE_VECTOR2: Vector2(0, 0),
		TYPE_COLOR: Color.DARK_ORANGE,
		TYPE_BOOL: true,
	}

	const FALLBACK_CHANGE_FOR_TYPE = {
		TYPE_INT: 1,
		TYPE_FLOAT: 1.0,
		TYPE_VECTOR2: Vector2(1, 1),
		TYPE_COLOR: Color.DARK_ORANGE,
	}

	if variant_type:
		var type_string: String = Types.VARIANT_TYPE_TO_STRING[variant_type]

		var bd = BlockDefinition.new()
		bd.name = "set_prop_%s" % property.name
		bd.type = Types.BlockType.STATEMENT
		bd.display_template = "Set %s to {value: %s}" % [property.name.capitalize(), type_string]
		bd.code_template = "%s = {value}" % property.name
		var default_set = property.get("default_set", FALLBACK_SET_FOR_TYPE.get(variant_type, ""))
		bd.defaults = {"value": default_set}
		bd.category = property.category

		block_definition_list.append(bd)

		if property.get("has_change", true):
			bd = BlockDefinition.new()
			bd.name = "change_prop_%s" % property.name
			bd.type = Types.BlockType.STATEMENT
			bd.display_template = "Change %s by {value: %s}" % [property.name.capitalize(), type_string]
			bd.code_template = "%s += {value}" % property.name
			var default_change = property.get("default_change", FALLBACK_CHANGE_FOR_TYPE[variant_type])
			bd.defaults = {"value": default_change}
			bd.category = property.category
			block_definition_list.append(bd)

		bd = BlockDefinition.new()
		bd.name = "get_prop_%s" % property.name
		bd.type = Types.BlockType.VALUE
		bd.variant_type = variant_type
		bd.display_template = "%s" % property.name.capitalize()
		bd.code_template = "%s" % property.name
		bd.category = property.category
		block_definition_list.append(bd)

	return block_definition_list


static func blocks_from_property_list(property_list: Array, selected_props: Dictionary) -> Array[BlockDefinition]:
	var block_definition_list: Array[BlockDefinition]

	for selected_property in selected_props:
		var found_prop
		for prop in property_list:
			if selected_property == prop.name:
				found_prop = prop
				found_prop.merge(selected_props[selected_property])
				break
		if found_prop:
			block_definition_list.append_array(property_to_blocklist(found_prop))
		else:
			push_warning("No property matching %s found in %s" % [selected_property, property_list])

	return block_definition_list


static func get_inherited_blocks(_class_name: String) -> Array[BlockDefinition]:
	var block_definition_list: Array[BlockDefinition] = []

	var current: String = _class_name

	while current != "":
		block_definition_list.append_array(get_built_in_blocks(current))
		current = ClassDB.get_parent_class(current)

	return block_definition_list


static func get_built_in_blocks(_class_name: String) -> Array[BlockDefinition]:
	var props: Dictionary = {}
	var block_definition_list: Array[BlockDefinition] = []

	match _class_name:
		"Node2D":
			props = {
				"position":
				{
					"category": "Transform | Position",
					"default_set": Vector2(100, 100),
					"default_change": Vector2(1, 1),
				},
				"rotation_degrees":
				{
					"category": "Transform | Rotation",
					"default_set": 45.0,
					"default_change": 1.0,
				},
				"scale":
				{
					"category": "Transform | Scale",
					"default_set": Vector2(2, 2),
					"default_change": Vector2(0.1, 0.1),
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
				var bd = BlockDefinition.new()
				bd.name = "rigidbody2d_on_%s" % verb
				bd.type = Types.BlockType.ENTRY
				bd.display_template = "On [body: OBJECT] %s" % [verb]
				bd.code_template = "func _on_body_%s(body: Node):" % [verb]
				bd.signal_name = "body_%s" % [verb]
				bd.category = "Communication | Methods"
				block_definition_list.append(bd)

			var bd = BlockDefinition.new()
			bd.name = "rigidbody2d_physics_position"
			bd.type = Types.BlockType.STATEMENT
			bd.display_template = "Set Physics Position {position: VECTOR2}"
			bd.code_template = (
				"""
				PhysicsServer2D.body_set_state(
					get_rid(),
					PhysicsServer2D.BODY_STATE_TRANSFORM,
					Transform2D.IDENTITY.translated({position})
				)
				"""
				. dedent()
			)
			bd.defaults = {
				"position": Vector2(0, 0),
			}
			bd.category = "Transform | Position"
			block_definition_list.append(bd)

			props = {
				"mass": {"category": "Physics | Mass"},
				"linear_velocity": {"category": "Physics | Velocity"},
				"angular_velocity": {"category": "Physics | Velocity"},
			}

		"AnimationPlayer":
			var bd = BlockDefinition.new()
			bd.name = "animationplayer_play"
			bd.type = Types.BlockType.STATEMENT
			bd.display_template = "Play {animation: STRING} {direction: OPTION}"
			bd.code_template = (
				"""
				if "{direction}" == "ahead":
					play({animation})
				else:
					play_backwards({animation})
				"""
				. dedent()
			)
			bd.defaults = {
				"direction": OptionData.new(["ahead", "backwards"]),
			}
			bd.tooltip_text = "Play the animation."
			bd.category = "Graphics | Animation"
			block_definition_list.append(bd)

			bd = BlockDefinition.new()
			bd.name = "animationplayer_pause"
			bd.type = Types.BlockType.STATEMENT
			bd.display_template = "Pause"
			bd.code_template = "pause()"
			bd.tooltip_text = "Pause the currently playing animation."
			bd.category = "Graphics | Animation"
			block_definition_list.append(bd)

			bd = BlockDefinition.new()
			bd.name = "animationplayer_stop"
			bd.type = Types.BlockType.STATEMENT
			bd.display_template = "Stop"
			bd.code_template = "stop()"
			bd.tooltip_text = "Stop the currently playing animation."
			bd.category = "Graphics | Animation"
			block_definition_list.append(bd)

			bd = BlockDefinition.new()
			bd.name = "animationplayer_is_playing"
			bd.type = Types.BlockType.STATEMENT
			bd.variant_type = TYPE_BOOL
			bd.display_template = "Is playing"
			bd.code_template = "is_playing()"
			bd.tooltip_text = "Check if an animation is currently playing."
			bd.category = "Graphics | Animation"
			block_definition_list.append(bd)

		"Area2D":
			for verb in ["entered", "exited"]:
				var bd = BlockDefinition.new()
				bd.name = "area2d_on_%s" % verb
				bd.type = Types.BlockType.ENTRY
				bd.display_template = "On [body: OBJECT] %s" % [verb]
				bd.code_template = "func _on_body_%s(body: Node):" % [verb]
				bd.signal_name = "body_%s" % [verb]
				bd.category = "Communication | Methods"
				block_definition_list.append(bd)

		"CharacterBody2D":
			var bd = BlockDefinition.new()
			bd.name = "characterbody2d_move"
			bd.category = "Input"
			bd.type = Types.BlockType.STATEMENT
			bd.display_template = "Move with keys {up: STRING} {down: STRING} {left: STRING} {right: STRING} with speed {speed: VECTOR2}"
			bd.code_template = (
				"var dir = Vector2()\n"
				+ "dir.x += float(Input.is_key_pressed(OS.find_keycode_from_string({right})))\n"
				+ "dir.x -= float(Input.is_key_pressed(OS.find_keycode_from_string({left})))\n"
				+ "dir.y += float(Input.is_key_pressed(OS.find_keycode_from_string({down})))\n"
				+ "dir.y -= float(Input.is_key_pressed(OS.find_keycode_from_string({up})))\n"
				+ "dir = dir.normalized()\n"
				+ "velocity = dir*{speed}\n"
				+ "move_and_slide()"
			)
			bd.defaults = {
				"up": "W",
				"down": "S",
				"left": "A",
				"right": "D",
				"speed": Vector2(100, 100),
			}
			block_definition_list.append(bd)

			bd = BlockDefinition.new()
			bd.name = "characterbody2d_move_and_slide"
			bd.type = Types.BlockType.STATEMENT
			bd.display_template = "Move and slide"
			bd.code_template = "move_and_slide()"
			bd.category = "Physics | Velocity"
			block_definition_list.append(bd)

			props = {
				"velocity": {"category": "Physics | Velocity"},
			}

	var prop_list = ClassDB.class_get_property_list(_class_name, true)
	block_definition_list.append_array(blocks_from_property_list(prop_list, props))

	return block_definition_list


static func _get_input_blocks() -> Array[BlockDefinition]:
	var block_definition_list: Array[BlockDefinition] = []

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

	var bd: BlockDefinition = BlockDefinition.new()
	bd.name = "is_action"
	bd.type = Types.BlockType.VALUE
	bd.variant_type = TYPE_BOOL
	bd.display_template = "Is action {action_name: OPTION} {action: OPTION}"
	bd.code_template = 'Input.is_action_{action}("{action_name}")'
	bd.defaults = {"action_name": OptionData.new(InputMap.get_actions()), "action": OptionData.new(["pressed", "just_pressed", "just_released"])}
	bd.category = "Input"
	block_definition_list.append(bd)

	if Engine.is_editor_hint():
		for action in editor_input_actions.keys():
			InputMap.add_action(action, editor_input_action_deadzones[action])
			for event in editor_input_actions[action]:
				InputMap.action_add_event(action, event)

	return block_definition_list


static func get_variable_blocks(variables: Array[VariableResource]) -> Array[BlockDefinition]:
	var block_definition_list: Array[BlockDefinition] = []

	for variable in variables:
		var type_string: String = Types.VARIANT_TYPE_TO_STRING[variable.var_type]

		var bd = BlockDefinition.new()
		bd.name = "get_var_%s" % variable.var_name
		bd.type = Types.BlockType.VALUE
		bd.variant_type = variable.var_type
		bd.display_template = variable.var_name
		bd.code_template = variable.var_name
		bd.category = "Variables"
		block_definition_list.append(bd)

		bd = BlockDefinition.new()
		bd.name = "set_var_%s" % variable.var_name
		bd.type = Types.BlockType.STATEMENT
		bd.display_template = "Set %s to {value: %s}" % [variable.var_name, type_string]
		bd.code_template = "%s = {value}" % [variable.var_name]
		bd.category = "Variables"
		block_definition_list.append(bd)

	return block_definition_list


static func get_blocks_from_block_script(block_script: BlockScriptSerialization) -> Array[BlockDefinition]:
	var blocks: Array[BlockDefinition] = []
	# By default, assume the class is built-in.
	var parent_class: String = block_script.script_inherits
	for class_dict in ProjectSettings.get_global_class_list():
		if class_dict.class == block_script.script_inherits:
			var script = load(class_dict.path)
			if script.has_method("get_custom_blocks"):
				parent_class = str(script.get_instance_base_type())
				blocks.append_array(script.get_custom_blocks())
			break

	blocks.append_array(get_inherited_blocks(parent_class))

	return blocks


static func get_categories_from_block_script(block_script: BlockScriptSerialization) -> Array[BlockCategory]:
	for class_dict in ProjectSettings.get_global_class_list():
		if class_dict.class == block_script.script_inherits:
			var script = load(class_dict.path)
			if script.has_method("get_custom_categories"):
				return script.get_custom_categories()

	return []
