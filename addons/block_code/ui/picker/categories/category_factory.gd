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

static var block_resource_dictionary: Dictionary


static func init_block_resource_dictionary():
	block_resource_dictionary = {}

	var path: String = "res://addons/block_code/blocks/"
	var files := get_files_in_dir_recursive(path, ".tres")

	for file in files:
		var block_resource = load(file)
		block_resource_dictionary[block_resource.block_name] = block_resource


static func get_files_in_dir_recursive(path: String, ext: String) -> Array:
	var files = []

	var dir := DirAccess.open(path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			var file_path = path + "/" + file_name
			if dir.current_is_dir():
				files.append_array(get_files_in_dir_recursive(file_path, ext))
			elif file_name.ends_with(".tres"):
				files.append(file_path)

			file_name = dir.get_next()

	return files


## Compare block categories for sorting. Compare by order then name.
static func _category_cmp(a: BlockCategory, b: BlockCategory) -> bool:
	if a.order != b.order:
		return a.order < b.order
	return a.name.naturalcasecmp_to(b.name) < 0


static func get_categories(blocks: Array[BlockResource], extra_categories: Array[BlockCategory] = []) -> Array[BlockCategory]:
	var cat_map: Dictionary = {}
	var extra_cat_map: Dictionary = {}

	for cat in extra_categories:
		extra_cat_map[cat.name] = cat

	for block in blocks:
		var block_cat_name: String = block.category
		var cat: BlockCategory = cat_map.get(block_cat_name)
		if cat == null:
			cat = extra_cat_map.get(block_cat_name)
			if cat == null:
				var props: Dictionary = BUILTIN_PROPS.get(block_cat_name, {})
				var color: Color = props.get("color", Color.SLATE_GRAY)
				var order: int = props.get("order", 0)
				cat = BlockCategory.new(block_cat_name, color, order)
			cat_map[block_cat_name] = cat
		cat.block_list.append(block)

	# Dictionary.values() returns an untyped Array and there's no way to
	# convert an array type besides Array.assign().
	var cats: Array[BlockCategory] = []
	cats.assign(cat_map.values())

	# Always add variables category (if no variable block built in)
	#var variable_cat_props = CategoryFactory.BUILTIN_PROPS["Variables"]
	#cats.append(BlockCategory.new("Variables", variable_cat_props.color, variable_cat_props.order))

	# Accessing a static Callable from a static function fails in 4.2.1.
	# Use the fully qualified name.
	# https://github.com/godotengine/godot/issues/86032
	cats.sort_custom(CategoryFactory._category_cmp)

	return cats


static func get_block_resource_from_name(block_name: String) -> BlockResource:
	if not block_name in block_resource_dictionary:
		push_error("Cannot construct unknown block name.")
		return null

	return block_resource_dictionary[block_name]


static func construct_block_from_name(block_name: String):
	var block_resource: BlockResource = get_block_resource_from_name(block_name)
	return construct_block_from_resource(block_resource)


# Essentially: Create UI from block resource.
# Using current API but we can make a cleaner one
static func construct_block_from_resource(block_resource: BlockResource):
	if block_resource == null:
		push_error("Cannot construct block from null block resource.")
		return null

	var block: Block

	if block_resource.block_type == Types.BlockType.STATEMENT:
		block = BLOCKS["statement_block"].instantiate()
	elif block_resource.block_type == Types.BlockType.ENTRY:
		block = BLOCKS["entry_block"].instantiate()
	elif block_resource.block_type == Types.BlockType.VALUE:
		block = BLOCKS["parameter_block"].instantiate()
	elif block_resource.block_type == Types.BlockType.CONTROL:
		block = BLOCKS["control_block"].instantiate()
	else:
		push_error("Other block types not implemented yet.")
		return null

	block.block_resource = block_resource

	return block


static func construct_blocks_from_resource_list(block_resource_list: Array[BlockResource]) -> Array[Block]:
	var block_list: Array[Block]  # FIXME: Assign cast
	block_list.assign(block_resource_list.map(construct_block_from_resource))
	return block_list


static func get_general_blocks() -> Array[BlockResource]:
	var block_resource_list: Array[BlockResource]  # FIXME: Assign cast
	block_resource_list.assign(block_resource_dictionary.values())

#region Input
	block_resource_list.append_array(_get_input_blocks())
#endregion

	return block_resource_list


static func get_parameter_output_blocks(block_resource_list: Array[BlockResource]) -> Array[BlockResource]:
	var param_output_blocks: Array[BlockResource] = []

	for block_resource in block_resource_list:
		# Block must be entry to have parameter outputs (helps with performance of this method)
		if block_resource.block_type != Types.BlockType.ENTRY:
			continue

		var regex = RegEx.create_from_string("\\[([^\\]]+)\\]")  # Capture things of format [test]
		var results := regex.search_all(block_resource.block_format)

		for result in results:
			var param := result.get_string()
			param = param.substr(1, param.length() - 2)
			var split := param.split(": ")

			var param_name := split[0]
			var param_type_str := split[1]
			var param_type = Types.STRING_TO_VARIANT_TYPE[param_type_str]

			var br = BlockResource.new()
			br.block_name = block_resource.statement + "_" + param_name
			br.block_type = Types.BlockType.VALUE
			br.block_format = param_name
			br.statement = param_name
			br.variant_type = param_type
			br.category = block_resource.category

			param_output_blocks.append(br)

	return param_output_blocks


static func property_to_blocklist(property: Dictionary) -> Array[BlockResource]:
	var block_resource_list: Array[BlockResource] = []

	var variant_type = property.type

	if variant_type:
		var type_string: String = Types.VARIANT_TYPE_TO_STRING[variant_type]

		var br := BlockResource.new()
		br.block_type = Types.BlockType.STATEMENT
		br.block_name = "set_prop_%s" % property.name
		br.block_format = "Set %s to {value: %s}" % [property.name.capitalize(), type_string]
		br.statement = "%s = {value}" % property.name
		br.category = property.category
		block_resource_list.append(br)

		br = BlockResource.new()
		br.block_type = Types.BlockType.STATEMENT
		br.block_name = "change_prop_%s" % property.name
		br.block_format = "Change %s by {value: %s}" % [property.name.capitalize(), type_string]
		br.statement = "%s += {value}" % property.name
		br.category = property.category
		block_resource_list.append(br)

		br = BlockResource.new()
		br.block_type = Types.BlockType.VALUE
		br.block_name = "get_prop_%s" % property.name
		br.variant_type = variant_type
		br.block_format = "%s" % property.name.capitalize()
		br.statement = "%s" % property.name
		br.category = property.category
		block_resource_list.append(br)

	return block_resource_list


static func blocks_from_property_list(property_list: Array, selected_props: Dictionary) -> Array[BlockResource]:
	var block_resource_list: Array[BlockResource]

	for selected_property in selected_props:
		var found_prop
		for prop in property_list:
			if selected_property == prop.name:
				found_prop = prop
				found_prop.category = selected_props[selected_property]
				break
		if found_prop:
			block_resource_list.append_array(property_to_blocklist(found_prop))
		else:
			push_warning("No property matching %s found in %s" % [selected_property, property_list])

	return block_resource_list


static func get_inherited_blocks(_class_name: String) -> Array[BlockResource]:
	var block_resource_list: Array[BlockResource] = []

	var current: String = _class_name

	while current != "":
		block_resource_list.append_array(get_built_in_blocks(current))
		current = ClassDB.get_parent_class(current)

	return block_resource_list


static func get_built_in_blocks(_class_name: String) -> Array[BlockResource]:
	var props: Dictionary = {}
	var block_resource_list: Array[BlockResource] = []

	match _class_name:
		"Node2D":
			var br := BlockResource.new()
			br.block_name = "node2d_rotation"
			br.block_type = Types.BlockType.STATEMENT
			br.block_format = "Set Rotation Degrees {angle: FLOAT}"
			br.statement = "rotation_degrees = {angle}"
			br.category = "Transform | Rotation"
			block_resource_list.append(br)

			props = {
				"position": "Transform | Position",
				"rotation": "Transform | Rotation",
				"scale": "Transform | Scale",
			}

		"CanvasItem":
			props = {"modulate": "Graphics | Modulate", "visible": "Graphics | Visibility"}

		"RigidBody2D":
			for verb in ["entered", "exited"]:
				var br = BlockResource.new()
				br.block_name = "rigidbody2d_on_%s" % verb
				br.block_type = Types.BlockType.ENTRY
				br.block_format = "On [body: OBJECT] %s" % [verb]
				br.statement = "func _on_body_%s(body: Node):" % [verb]
				br.signal_name = "body_%s" % [verb]
				br.category = "Communication | Methods"
				block_resource_list.append(br)

			var br = BlockResource.new()
			br.block_name = "rigidbody2d_physics_position"
			br.block_type = Types.BlockType.STATEMENT
			br.block_format = "Set Physics Position {position: VECTOR2}"
			br.statement = (
				"""
				PhysicsServer2D.body_set_state(
					get_rid(),
					PhysicsServer2D.BODY_STATE_TRANSFORM,
					Transform2D.IDENTITY.translated({position})
				)
				"""
				. dedent()
			)
			br.category = "Transform | Position"
			block_resource_list.append(br)

			props = {"mass": "Physics | Mass", "linear_velocity": "Physics | Velocity", "angular_velocity": "Physics | Velocity"}

		"AnimationPlayer":
			var br = BlockResource.new()
			br.block_name = "animationplayer_play"
			br.block_type = Types.BlockType.STATEMENT
			br.block_format = "Play {animation: STRING} {direction: OPTION}"
			br.statement = (
				"""
				if "{direction}" == "ahead":
					play({animation})
				else:
					play_backwards({animation})
				"""
				. dedent()
			)
			br.defaults = {
				"direction": OptionData.new(["ahead", "backwards"]),
			}
			br.tooltip_text = "Play the animation."
			br.category = "Graphics | Animation"
			block_resource_list.append(br)

			br = BlockResource.new()
			br.block_name = "animationplayer_pause"
			br.block_type = Types.BlockType.STATEMENT
			br.block_format = "Pause"
			br.statement = "pause()"
			br.tooltip_text = "Pause the currently playing animation."
			br.category = "Graphics | Animation"
			block_resource_list.append(br)

			br = BlockResource.new()
			br.block_name = "animationplayer_stop"
			br.block_type = Types.BlockType.STATEMENT
			br.block_format = "Stop"
			br.statement = "stop()"
			br.tooltip_text = "Stop the currently playing animation."
			br.category = "Graphics | Animation"
			block_resource_list.append(br)

			br = BlockResource.new()
			br.block_name = "animationplayer_is_playing"
			br.block_type = Types.BlockType.STATEMENT
			br.variant_type = TYPE_BOOL
			br.block_format = "Is playing"
			br.statement = "is_playing()"
			br.tooltip_text = "Check if an animation is currently playing."
			br.category = "Graphics | Animation"
			block_resource_list.append(br)

		"Area2D":
			for verb in ["entered", "exited"]:
				var br = BlockResource.new()
				br.block_name = "area2d_on_%s" % verb
				br.block_type = Types.BlockType.ENTRY
				br.block_format = "On [body: OBJECT] %s" % [verb]
				br.statement = "func _on_body_%s(body: Node):" % [verb]
				br.signal_name = "body_%s" % [verb]
				br.category = "Communication | Methods"
				block_resource_list.append(br)

		"CharacterBody2D":
			var br = BlockResource.new()
			br.block_name = "characterbody2d_move"
			br.block_type = Types.BlockType.STATEMENT
			br.block_format = "Move with keys {up: STRING} {down: STRING} {left: STRING} {right: STRING} with speed {speed: VECTOR2}"
			br.statement = (
				"var dir = Vector2()\n"
				+ "dir.x += float(Input.is_key_pressed(OS.find_keycode_from_string({right})))\n"
				+ "dir.x -= float(Input.is_key_pressed(OS.find_keycode_from_string({left})))\n"
				+ "dir.y += float(Input.is_key_pressed(OS.find_keycode_from_string({down})))\n"
				+ "dir.y -= float(Input.is_key_pressed(OS.find_keycode_from_string({up})))\n"
				+ "dir = dir.normalized()\n"
				+ "velocity = dir*{speed}\n"
				+ "move_and_slide()"
			)
			br.defaults = {
				"up": "W",
				"down": "S",
				"left": "A",
				"right": "D",
			}
			br.category = "Input"
			block_resource_list.append(br)

			br = BLOCKS["statement_block"].instantiate()
			br.block_name = "characterbody2d_move_and_slide"
			br.block_type = Types.BlockType.STATEMENT
			br.block_format = "Move and slide"
			br.statement = "move_and_slide()"
			br.category = "Physics | Velocity"
			block_resource_list.append(br)

			props = {"velocity": "Physics | Velocity"}

	var prop_list = ClassDB.class_get_property_list(_class_name, true)
	block_resource_list.append_array(blocks_from_property_list(prop_list, props))

	return block_resource_list


static func _get_input_blocks() -> Array[BlockResource]:
	var block_resource_list: Array[BlockResource] = []

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

	var br: BlockResource = BlockResource.new()
	br.block_name = "is_action"
	br.block_type = Types.BlockType.VALUE
	br.variant_type = TYPE_BOOL
	br.block_format = "Is action {action_name: OPTION} {action: OPTION}"
	br.statement = 'Input.is_action_{action}("{action_name}")'
	br.defaults = {"action_name": OptionData.new(InputMap.get_actions()), "action": OptionData.new(["pressed", "just_pressed", "just_released"])}
	br.category = "Input"
	block_resource_list.append(br)

	if Engine.is_editor_hint():
		for action in editor_input_actions.keys():
			InputMap.add_action(action, editor_input_action_deadzones[action])
			for event in editor_input_actions[action]:
				InputMap.action_add_event(action, event)

	return block_resource_list


static func get_variable_blocks(variables: Array[VariableResource]) -> Array[BlockResource]:
	var block_resource_list: Array[BlockResource] = []

	for variable in variables:
		var type_string: String = Types.VARIANT_TYPE_TO_STRING[variable.var_type]

		var br = BlockResource.new()
		br.block_name = "get_var_%s" % variable.var_name
		br.block_type = Types.BlockType.VALUE
		br.variant_type = variable.var_type
		br.block_format = variable.var_name
		br.statement = variable.var_name
		br.category = "Variables"
		block_resource_list.append(br)

		br = BlockResource.new()
		br.block_name = "set_var_%s" % variable.var_name
		br.block_type = Types.BlockType.STATEMENT
		br.block_format = "Set %s to {value: %s}" % [variable.var_name, type_string]
		br.statement = "%s = {value}" % [variable.var_name]
		br.category = "Variables"
		block_resource_list.append(br)

	return block_resource_list


static func get_blocks_from_bsd(bsd: BlockScriptData) -> Array[BlockResource]:
	var blocks: Array[BlockResource] = []
	# By default, assume the class is built-in.
	var parent_class: String = bsd.script_inherits
	for class_dict in ProjectSettings.get_global_class_list():
		if class_dict.class == bsd.script_inherits:
			var script = load(class_dict.path)
			if script.has_method("get_custom_blocks"):
				parent_class = str(script.get_instance_base_type())
				blocks.append_array(script.get_custom_blocks())

	blocks.append_array(get_inherited_blocks(bsd.script_inherits))

	return blocks


static func get_categories_from_bsd(bsd: BlockScriptData) -> Array[BlockCategory]:
	for class_dict in ProjectSettings.get_global_class_list():
		if class_dict.class == bsd.script_inherits:
			var script = load(class_dict.path)
			if script.has_method("get_custom_categories"):
				return script.get_custom_categories()

	return []
