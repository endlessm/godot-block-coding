@tool

extends Resource

const Types = preload("res://addons/block_code/types/types.gd")

const FORMAT_STRING_PATTERN = "\\[(?<out_parameter>[^\\]]+)\\]|\\{(?<in_parameter>[^}]+)\\}|(?<label>[^\\{\\[]+)"

@export var name: StringName

## The target node. Leaving this empty the block is considered a general block
## (for any node).
@export var target_node_class: String

@export_multiline var description: String
@export var category: String

@export var type: Types.BlockType
@export var variant_type: Variant.Type

@export var display_template: String
@export_multiline var code_template: String
@export var defaults: Dictionary

## Only for blocks of type Types.ENTRY. If non-empty, this block defines a
## callback that will be connected to the signal with this name.
@export var signal_name: String

## Empty except for blocks that have a defined scope
@export var scope: String

@export var extension_script: GDScript

static var _display_template_regex := RegEx.create_from_string(FORMAT_STRING_PATTERN)

var _extension: BlockExtension:
	get:
		if _extension == null and extension_script and extension_script.can_instantiate():
			_extension = extension_script.new()
		return _extension as BlockExtension


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


func get_defaults_for_node(parent_node: Node) -> Dictionary:
	if not _extension:
		return defaults

	# Use Dictionary.merge instead of Dictionary.merged for Godot 4.2 compatibility
	var new_defaults := _extension.get_defaults_for_node(parent_node)
	new_defaults.merge(defaults)
	return new_defaults


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
	for regex_match in _display_template_regex.search_all(template_string):
		if regex_match.names.has("label"):
			var label_string := regex_match.get_string("label")
			items.append({"label": label_string})
		elif regex_match.names.has("in_parameter"):
			var parameter_string := regex_match.get_string("in_parameter")
			items.append({"in_parameter": _parse_parameter_format(parameter_string)})
		elif regex_match.names.has("out_parameter"):
			var parameter_string := regex_match.get_string("out_parameter")
			items.append({"out_parameter": _parse_parameter_format(parameter_string)})
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
