@tool
class_name TemplateEditor
extends Container

signal drag_started(offset: Vector2)
signal modified

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlockTreeUtil = preload("res://addons/block_code/ui/block_tree_util.gd")
const OptionData = preload("res://addons/block_code/code_generation/option_data.gd")
const ParameterInput = preload("res://addons/block_code/ui/blocks/utilities/parameter_input/parameter_input.gd")
const ParameterInputScene = preload("res://addons/block_code/ui/blocks/utilities/parameter_input/parameter_input.tscn")
const ParameterOutput = preload("res://addons/block_code/ui/blocks/utilities/parameter_output/parameter_output.gd")
const ParameterOutputScene = preload("res://addons/block_code/ui/blocks/utilities/parameter_output/parameter_output.tscn")

const FORMAT_STRING_PATTERN = "\\[(?<out_parameter>[^\\]]+)\\]|\\{(?<in_parameter>[^}]+)\\}|(?<label>[^\\{\\[]+)"

## A string describing a block's display format. For example:
## [br]
## [code]
## Print {text: STRING}
## [/code]
## [br]
## This component's children will be generated based on the format string,
## with [code]ParameterInput[/code] and [code]ParameterOutput[/code] nodes in
## place of any parameters of format [code]{foo}[/code] or [code][foo][/code].
@export var format_string: String:
	set(value):
		format_string = value
		_update_from_format_string()

## A dictionary describing default values for a block's parameters. The keys of
## the dictionary must match the list of parameters in [param format_string].
## The values should be the same type as the parameter.
@export var parameter_defaults: Dictionary:
	set(value):
		parameter_defaults = value
		_update_from_format_string()

var parent_block: Block
var _parameter_inputs_by_name: Dictionary

@onready var _container := %Container
@onready var _regex := RegEx.create_from_string(FORMAT_STRING_PATTERN)


func _ready() -> void:
	parent_block = BlockTreeUtil.get_parent_block(self)

	_update_from_format_string()


## Set the values of all input parameters based from a dictionary of raw values.
## Parameters not included in [param raw_values] will be reset to their
## defaults according to [member parameter_defaults].
func set_parameter_values(raw_values: Dictionary):
	for parameter_name in _parameter_inputs_by_name:
		var parameter_input: ParameterInput = _parameter_inputs_by_name[parameter_name]
		var parameter_value: Variant = raw_values.get(parameter_name)

		parameter_input.set_raw_input(parameter_value)


func get_parameter_values() -> Dictionary:
	var result: Dictionary

	for parameter_name in _parameter_inputs_by_name:
		var parameter_input: ParameterInput = _parameter_inputs_by_name[parameter_name]
		result[parameter_name] = parameter_input.get_raw_input()

	return result


func format_statement(statement: String) -> String:
	return _parameter_inputs_by_name.keys().reduce(_replace_parameter_in_statement, statement)


func _replace_parameter_in_statement(statement: String, parameter_name: String) -> String:
	var parameter_input: ParameterInput = _parameter_inputs_by_name[parameter_name]
	return statement.replace("{%s}" % parameter_name, parameter_input.get_string())


func _update_from_format_string():
	if not _container:
		return

	_parameter_inputs_by_name = {}
	for child in _container.get_children():
		_container.remove_child(child)
		child.queue_free()

	var match_id = 0
	for item in BlockDefinition.parse_display_template(format_string):
		if item.has("label"):
			_append_label(item.get("label"))
		elif item.has("in_parameter"):
			_append_input_parameter(item.get("in_parameter"), match_id)
		elif item.has("out_parameter"):
			_append_output_parameter(item.get("out_parameter"), match_id)
		match_id += 1


func _append_label(label_format: String):
	var label = Label.new()
	label.add_theme_color_override("font_color", Color.WHITE)
	label.text = label_format.strip_edges()
	_container.add_child(label)


func _append_input_parameter(parameter: Dictionary, id: int):
	var default_value = parameter_defaults.get(parameter["name"])

	var parameter_input: ParameterInput = ParameterInputScene.instantiate()
	parameter_input.name = "ParameterInput%d" % id
	parameter_input.placeholder = parameter["name"]
	parameter_input.variant_type = parameter["type"]
	parameter_input.drag_started.connect(_on_parameter_input_drag_started)

	if default_value is OptionData:
		var option_data := default_value as OptionData
		parameter_input.option_data = option_data
		if option_data.selected < option_data.items.size():
			parameter_input.default_value = option_data.items[option_data.selected]
	else:
		parameter_input.default_value = default_value

	parameter_input.modified.connect(func(): modified.emit())

	_container.add_child(parameter_input)
	_parameter_inputs_by_name[parameter["name"]] = parameter_input


func _append_output_parameter(parameter: Dictionary, id: int):
	var parameter_output: ParameterOutput

	parameter_output = ParameterOutputScene.instantiate()
	parameter_output.name = "ParameterOutput%d" % id
	parameter_output.block = parent_block
	parameter_output.parameter_name = parameter["name"]
	_container.add_child(parameter_output)


func _on_parameter_input_drag_started(offset: Vector2):
	drag_started.emit(offset)
