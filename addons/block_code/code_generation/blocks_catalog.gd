extends Object

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const Types = preload("res://addons/block_code/types/types.gd")
const Util = preload("res://addons/block_code/code_generation/util.gd")
const VariableDefinition = preload("res://addons/block_code/code_generation/variable_definition.gd")

const _BLOCKS_PATH = "res://addons/block_code/blocks/"

const _FALLBACK_SET_FOR_TYPE = {
	TYPE_BOOL: false,
	TYPE_INT: 0,
	TYPE_FLOAT: 0.0,
	TYPE_VECTOR2: Vector2(0, 0),
	TYPE_VECTOR3: Vector3(0, 0, 0),
	TYPE_COLOR: Color.DARK_ORANGE,
}

const _FALLBACK_CHANGE_FOR_TYPE = {
	TYPE_BOOL: true,
	TYPE_INT: 1,
	TYPE_FLOAT: 1.0,
	TYPE_VECTOR2: Vector2(1, 1),
	TYPE_VECTOR3: Vector3(1, 1, 1),
	TYPE_COLOR: Color.DARK_ORANGE,
}

const _SETTINGS_FOR_CLASS_PROPERTY = {
	"Node2D":
	{
		"position":
		{
			"category": "Transform | Position",
			"default_set": Vector2(100, 100),
			"default_change": Vector2(1, 1),
		},
		"rotation_degrees":
		{
			"category": "Transform | Rotation",
			"default_set": 45,
			"default_change": 1,
		},
		"scale":
		{
			"category": "Transform | Scale",
			"default_set": Vector2(2, 2),
			"default_change": Vector2(0.1, 0.1),
		},
	},
	"Node3D":
	{
		"position":
		{
			"category": "Transform | Position",
			"default_set": Vector3(0, 0, 0),
			"default_change": Vector3(0.1, 0.1, 0.1),
		},
		"rotation":
		{
			"category": "Transform | Rotation",
			"default_set": Vector3(0, 0, 0),
			"default_change": Vector3(0.1, 0.1, 0.1),
		},
		"scale":
		{
			"category": "Transform | Scale",
			"default_set": Vector3(1, 1, 1),
			"default_change": Vector3(0.1, 0.1, 0.1),
		}
	},
	"CanvasItem":
	{
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
	},
	"RigidBody2D":
	{
		"mass": {"category": "Physics | Mass"},
		"linear_velocity": {"category": "Physics | Velocity"},
		"angular_velocity": {"category": "Physics | Velocity"},
	},
	"AudioStreamPlayer":
	{
		"stream_paused":
		{
			"category": "Sounds",
			"has_change": false,
		},
	},
	"CharacterBody2D":
	{
		"velocity": {"category": "Physics | Velocity"},
	},
	"CPUParticles2D":
	{
		"emitting":
		{
			"category": "Lifecycle | Spawn",
			"has_change": false,
		},
	},
}

static var _catalog: Dictionary


static func _setup_definitions_from_files():
	var definition_files = Util.get_files_in_dir_recursive(_BLOCKS_PATH, "*.tres")
	for file in definition_files:
		var block_definition: BlockDefinition = load(file)
		_catalog[block_definition.name] = block_definition
		var target = block_definition.target_node_class
		if not target:
			continue


static func _add_property_definitions(_class_name: String, property_list: Array[Dictionary], property_settings: Dictionary):
	for property in property_list:
		if not property.name in property_settings:
			continue
		var block_settings = property_settings[property.name]
		var type_string: String = Types.VARIANT_TYPE_TO_STRING[property.type]

		# Setter
		var block_definition: BlockDefinition
		if block_settings.get("has_setter", true):
			var default_value: Variant = block_settings.get("default_set", _FALLBACK_SET_FOR_TYPE[property.type])
			block_definition = BlockDefinition.new_property_setter(_class_name, property, block_settings.category, default_value)
			_catalog[block_definition.name] = block_definition

		# Changer
		if block_settings.get("has_change", true):
			var default_value: Variant = block_settings.get("default_change", _FALLBACK_CHANGE_FOR_TYPE[property.type])
			block_definition = BlockDefinition.new_property_changer(_class_name, property, block_settings.category, default_value)
			_catalog[block_definition.name] = block_definition

		# Getter
		block_definition = BlockDefinition.new_property_getter(_class_name, property, block_settings.category)
		_catalog[block_definition.name] = block_definition


static func _setup_properties_for_class():
	for _class_name in _SETTINGS_FOR_CLASS_PROPERTY:
		var property_list = ClassDB.class_get_property_list(_class_name, true)
		var property_settings = _SETTINGS_FOR_CLASS_PROPERTY[_class_name]
		_add_property_definitions(_class_name, property_list, property_settings)


static func setup():
	if _catalog:
		return

	_catalog = {}
	_setup_definitions_from_files()
	_setup_properties_for_class()


static func get_block(block_name: StringName):
	return _catalog.get(block_name)


static func has_block(block_name: StringName):
	return block_name in _catalog


static func _get_blocks_by_class(_class_name: String) -> Array[BlockDefinition]:
	var result: Array[BlockDefinition]
	result.assign(_catalog.values().filter(_block_definition_has_class_name.bind(_class_name)))
	return result


static func _block_definition_has_class_name(block_definition: BlockDefinition, _class_name: String) -> bool:
	return block_definition.target_node_class == _class_name


static func _get_builtin_parents(_class_name: String) -> Array[String]:
	var parents: Array[String] = []
	var current = _class_name

	while current != "":
		parents.append(current)
		current = ClassDB.get_parent_class(current)

	return parents


static func _get_custom_parent_class_name(_custom_class_name: String) -> String:
	for class_dict in ProjectSettings.get_global_class_list():
		if class_dict.class != _custom_class_name:
			continue
		var script = load(class_dict.path)
		var builtin_class = script.get_instance_base_type()
		return builtin_class
	return "Node"


static func get_parents(_class_name: String) -> Array[String]:
	if ClassDB.class_exists(_class_name):
		return _get_builtin_parents(_class_name)
	var parents: Array[String] = []
	if _class_name != "":
		parents.append(_class_name)
	var _parent_class_name = _get_custom_parent_class_name(_class_name)
	parents.append_array(_get_builtin_parents(_parent_class_name))
	return parents


static func get_inherited_blocks(_class_name: String) -> Array[BlockDefinition]:
	setup()

	var definitions: Array[BlockDefinition] = []
	for _parent_class_name in get_parents(_class_name):
		definitions.append_array(_get_blocks_by_class(_parent_class_name))
	definitions.append_array(_get_blocks_by_class(""))
	return definitions


static func add_custom_blocks(
	_class_name,
	block_definitions: Array[BlockDefinition] = [],
	property_list: Array[Dictionary] = [],
	property_settings: Dictionary = {},
):
	setup()

	for block_definition in block_definitions:
		_catalog[block_definition.name] = block_definition

	_add_property_definitions(_class_name, property_list, property_settings)


static func get_variable_block_definitions(variables: Array[VariableDefinition]) -> Array[BlockDefinition]:
	var block_definitions: Array[BlockDefinition] = []
	for variable: VariableDefinition in variables:
		block_definitions.append(BlockDefinition.new_variable_getter(variable))
		block_definitions.append(BlockDefinition.new_variable_setter(variable))

	return block_definitions


static func get_property_getter_block_definition(_class_name: String, property: Dictionary) -> BlockDefinition:
	var name = BlockDefinition.PROPERTY_GETTER_NAME_FORMAT % [_class_name, property.name]
	if name in _catalog:
		return _catalog[name]
	var block_definition := BlockDefinition.new_property_getter(_class_name, property, "Variables")
	_catalog[block_definition.name] = block_definition
	return block_definition


static func get_property_setter_block_definition(_class_name: String, property: Dictionary) -> BlockDefinition:
	var name = BlockDefinition.PROPERTY_SETTER_NAME_FORMAT % [_class_name, property.name]
	if name in _catalog:
		return _catalog[name]
	var default_value: Variant = _FALLBACK_SET_FOR_TYPE[property.type]
	var block_definition := BlockDefinition.new_property_setter(_class_name, property, "Variables", default_value)
	_catalog[block_definition.name] = block_definition
	return block_definition


static func get_resource_block_definition(file_path: String) -> BlockDefinition:
	var block_def := BlockDefinition.new()
	var file_name = file_path.get_file()

	# Block Definition's name cannot work with '.'
	block_def.name = &"get_resource_file_path"
	block_def.description = "The full resource path of '%s'" % file_name
	block_def.category = "Variables"
	block_def.type = Types.BlockType.VALUE
	block_def.variant_type = TYPE_STRING
	block_def.display_template = "%s {const file_path: STRING}" % file_name
	block_def.code_template = "{file_path}"
	block_def.defaults = {"file_path": file_path}

	return block_def
