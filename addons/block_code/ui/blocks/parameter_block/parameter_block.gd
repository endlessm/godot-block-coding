@tool
class_name ParameterBlock
extends Block

@export var block_format: String = ""
@export var statement: String = ""
@export var variant_type: Variant.Type

@onready var _panel := $Panel
@onready var _hbox := %HBoxContainer

var param_name_input_pairs: Array
var param_input_strings: Dictionary  # Only loaded from serialized


func _ready():
	super()

	block_type = Types.BlockType.VALUE
	var new_panel = _panel.get_theme_stylebox("panel").duplicate()
	new_panel.bg_color = color
	new_panel.border_color = color.darkened(0.2)
	_panel.add_theme_stylebox_override("panel", new_panel)

	format()

	if param_input_strings:
		for pair in param_name_input_pairs:
			pair[1].set_plain_text(param_input_strings[pair[0]])


func _on_drag_drop_area_mouse_down():
	_drag_started()


func get_serialized_props() -> Array:
	var props := super()
	props.append_array(serialize_props(["block_format", "statement", "variant_type"]))

	var _param_input_strings: Dictionary = {}
	for pair in param_name_input_pairs:
		_param_input_strings[pair[0]] = pair[1].get_plain_text()

	props.append(["param_input_strings", _param_input_strings])

	return props


# Override this method to create custom parameter functionality
func get_parameter_string() -> String:
	var formatted_statement := statement

	for pair in param_name_input_pairs:
		formatted_statement = formatted_statement.replace("{%s}" % pair[0], pair[1].get_string())

	return formatted_statement


static func get_block_class():
	return "ParameterBlock"


static func get_scene_path():
	return "res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn"


func format():
	param_name_input_pairs = StatementBlock.format_string(self, %HBoxContainer, block_format)
