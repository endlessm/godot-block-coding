@tool
extends Resource

const Types = preload("res://addons/block_code/types/types.gd")
const VariableDefinition = preload("res://addons/block_code/code_generation/variable_definition.gd")

const FORMAT_STRING_PATTERN = "\\[(?<out_parameter>[^\\]]+)\\]|\\{const (?<const_parameter>[^}]+)\\}|\\{(?!const )(?<in_parameter>[^}]+)\\}|(?<label>[^\\{\\[]+)"
const PROPERTY_SETTER_NAME_PATTERN = "(?<class_name>[^\\s]*)_set_(?<property_name>[^\\s]+)"
const PROPERTY_SETTER_NAME_FORMAT = &"%s_set_%s"
const PROPERTY_CHANGER_NAME_PATTERN = "(?<class_name>[^\\s]*)_change_(?<property_name>[^\\s]+)"
const PROPERTY_CHANGER_NAME_FORMAT = &"%s_change_%s"
const PROPERTY_GETTER_NAME_PATTERN = "(?<class_name>[^\\s]*)_get_(?<property_name>[^\\s]+)"
const PROPERTY_GETTER_NAME_FORMAT = &"%s_get_%s"
const VARIABLE_SETTER_NAME_FORMAT = &"set_var_%s"
const VARIABLE_GETTER_NAME_FORMAT = &"get_var_%s"

@export var name: StringName

## The target node. Leaving this empty the block is considered a general block
## (for any node).
@export var target_node_class: String

## A description for this block, which will be shown to the user in a tooltip.
@export_multiline var description: String

## The category under which this block will appear in the Picker.
@export var category: String

## Which kind of block is this. See [enum Types.BlockType].
@export var type: Types.BlockType:
	set = _set_type

## Only relevant for Value blocks. The variant type that this block is
## supposed to return.
@export var variant_type: Variant.Type

## Template for creating the UI of this block. That is, the labels and the
## parameters that will become user inputs with slots. The UI can be split
## between basic and advanced using the [code]|[/code] character as separator.
## Example:
## [codeblock]
## say {salute: STRING} | {fancy: BOOL}
## [/codeblock]
## If [member property_name] is set, this template is assumed to be a format
## string with a `%s` placeholder; in this case, any literal `%` signs must
## be escaped as `%%`.
@export var display_template: String

## Template for the generated GDScript code. This must be valid GDScript. The
## parameters in [member display_template] will be replaced by the user input
## or by the resulting value of snapped blocks.
## Following the example in [member display_template]:
## [codeblock]
## if {fancy}:
##     print_rich('[color=green][b]' + {salute} + '[/b][/color]')
## else:
##     print({salute})
## [/codeblock]
@export_multiline var code_template: String

## Optional defaults for the variables defined in [member display_template].
## The key must be of type String and match a variable name in both [member
## display_template] and [member code_template]. The value must be of the same
## type as defined in the [member display_template].
@export var defaults: Dictionary

## Only for blocks of type [member Types.BlockType.ENTRY]. If non-empty, this
## block defines a callback that will be connected to the signal with this
## name.
@export var signal_name: String

## If checked, the block will be hidden by default in the Picker.
@export var is_advanced: bool

## An optional script that can extend this block definition. For instance, to
## dynamically add the defaults.
@export var extension_script: GDScript

## Empty except for blocks that have a defined scope.
var scope: String

## Optional property name, for localizing it. Only relevant for property setters, changers and
## getters.
var property_name: String

static var _display_template_regex := RegEx.create_from_string(FORMAT_STRING_PATTERN)

static var property_setter_regex := RegEx.create_from_string(PROPERTY_SETTER_NAME_PATTERN)
static var property_changer_regex := RegEx.create_from_string(PROPERTY_CHANGER_NAME_PATTERN)
static var property_getter_regex := RegEx.create_from_string(PROPERTY_GETTER_NAME_PATTERN)


func _init(
	p_name: StringName = &"",
	p_target_node_class = "",
	p_description: String = "",
	p_category: String = "",
	p_type: Types.BlockType = Types.BlockType.STATEMENT,
	p_variant_type: Variant.Type = TYPE_NIL,
	p_display_template: String = "",
	p_code_template: String = "",
	p_defaults = {},
	p_signal_name: String = "",
	p_scope: String = "",
	p_extension_script: GDScript = null,
	p_is_advanced: bool = false,
):
	name = p_name
	target_node_class = p_target_node_class
	description = p_description
	category = p_category
	type = p_type
	variant_type = p_variant_type
	display_template = p_display_template
	code_template = p_code_template
	defaults = p_defaults
	signal_name = p_signal_name
	scope = p_scope
	extension_script = p_extension_script
	is_advanced = p_is_advanced


func _set_type(p_type):
	type = p_type
	notify_property_list_changed()


func _validate_property(property: Dictionary):
	if property.name == "variant_type" and type != Types.BlockType.VALUE:
		property.usage |= PROPERTY_USAGE_READ_ONLY
	elif property.name == "signal_name" and type != Types.BlockType.ENTRY:
		property.usage |= PROPERTY_USAGE_READ_ONLY


func create_block_extension() -> BlockExtension:
	if not extension_script:
		return null

	if not extension_script.can_instantiate():
		return null

	var extension := extension_script.new() as BlockExtension

	if not extension:
		push_warning("Error initializing block extension for %s.", self)
		return null

	return extension


func _to_string():
	return "%s - %s" % [name, target_node_class]


func get_output_parameters() -> Dictionary:
	var result: Dictionary
	for item in parse_display_template(display_template):
		if item.has("out_parameter"):
			var parameter = item.get("out_parameter")
			result[parameter["name"]] = parameter["type"]
	return result


static func parse_display_template(template_string: String):
	var items: Array[Dictionary]
	# Parse the template string.
	var parse_template_string = func(template_string: String, hidden: bool):
		for regex_match in _display_template_regex.search_all(template_string):
			if regex_match.names.has("label"):
				var label_string := regex_match.get_string("label")
				items.append({"label": label_string, "hidden": hidden})
			elif regex_match.names.has("in_parameter"):
				var parameter_string := regex_match.get_string("in_parameter")
				items.append({"in_parameter": _parse_parameter_format(parameter_string), "hidden": hidden})
			elif regex_match.names.has("out_parameter"):
				var parameter_string := regex_match.get_string("out_parameter")
				items.append({"out_parameter": _parse_parameter_format(parameter_string), "hidden": hidden})
			elif regex_match.names.has("const_parameter"):
				var parameter_string := regex_match.get_string("const_parameter")
				items.append({"const_parameter": _parse_parameter_format(parameter_string), "hidden": hidden})
	# This splits in two the template string in the first "|" character
	# to separate normal and hidden parameters.
	var sep: int = template_string.find("|")
	if sep == -1:
		parse_template_string.call(template_string, false)
	else:
		var template_string_normal := template_string.substr(0, sep).trim_suffix(" ")
		var template_string_advanced := template_string.substr(sep + 1)
		parse_template_string.call(template_string_normal, false)
		parse_template_string.call(template_string_advanced, true)
	return items


static func _parse_parameter_format(parameter_format: String) -> Dictionary:
	var parameter_name: String
	var parameter_type_str: String
	var parameter_type: Variant.Type
	var split := parameter_format.split(":", true, 1)

	if len(split) == 0:
		return {}

	if len(split) > 0:
		parameter_name = split[0].strip_edges()

	if len(split) > 1:
		parameter_type_str = split[1].strip_edges()

	if parameter_type_str:
		parameter_type = Types.STRING_TO_VARIANT_TYPE[parameter_type_str]

	return {"name": parameter_name, "type": parameter_type}


static func has_category(block_definition, category: String) -> bool:
	return block_definition.category == category


static func new_property_setter(_class_name: String, property: Dictionary, category: String, default_value: Variant) -> Resource:
	var type_string: String = Types.VARIANT_TYPE_TO_STRING[property.type]
	var block_definition: Resource = new(
		PROPERTY_SETTER_NAME_FORMAT % [_class_name, property.name],
		_class_name,
		Engine.tr("Set the %s property") % property.name,
		category,
		Types.BlockType.STATEMENT,
		TYPE_NIL,
		Engine.tr("set %%s to {value: %s}") % type_string,
		"%s = {value}" % property.name,
		{"value": default_value},
	)
	block_definition.property_name = property.name
	return block_definition


static func new_property_changer(_class_name: String, property: Dictionary, category: String, default_value: Variant) -> Resource:
	var type_string: String = Types.VARIANT_TYPE_TO_STRING[property.type]
	var block_definition: Resource = new(
		PROPERTY_CHANGER_NAME_FORMAT % [_class_name, property.name],
		_class_name,
		Engine.tr("Change the %s property") % property.name,
		category,
		Types.BlockType.STATEMENT,
		TYPE_NIL,
		Engine.tr("change %%s by {value: %s}") % type_string,
		"%s += {value}" % property.name,
		{"value": default_value},
	)
	block_definition.property_name = property.name
	return block_definition


static func new_property_getter(_class_name: String, property: Dictionary, category: String) -> Resource:
	var block_definition: Resource = new(
		PROPERTY_GETTER_NAME_FORMAT % [_class_name, property.name],
		_class_name,
		Engine.tr("The %s property") % property.name,
		category,
		Types.BlockType.VALUE,
		property.type,
		"%s",
		"%s" % property.name,
	)
	block_definition.property_name = property.name
	return block_definition


static func new_variable_setter(variable: VariableDefinition) -> Resource:
	var _type_string: String = Types.VARIANT_TYPE_TO_STRING[variable.var_type]
	var block_definition: Resource = new(
		VARIABLE_SETTER_NAME_FORMAT % variable.var_name,
		"",
		Engine.tr("Set the %s variable") % variable.var_name,
		"Variables",
		Types.BlockType.STATEMENT,
		TYPE_NIL,
		Engine.tr("set %s to {value: %s}") % [variable.var_name, _type_string],
		"%s = {value}" % variable.var_name,
	)
	return block_definition


static func new_variable_getter(variable: VariableDefinition) -> Resource:
	var block_definition: Resource = new(
		VARIABLE_GETTER_NAME_FORMAT % variable.var_name,
		"",
		Engine.tr("The %s variable") % variable.var_name,
		"Variables",
		Types.BlockType.VALUE,
		variable.var_type,
		"%s" % variable.var_name,
		"%s" % variable.var_name,
	)
	return block_definition
