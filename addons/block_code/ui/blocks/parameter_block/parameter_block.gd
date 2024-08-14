@tool
class_name ParameterBlock
extends Block

const Constants = preload("res://addons/block_code/ui/constants.gd")
const Util = preload("res://addons/block_code/ui/util.gd")

@export var block_format: String = ""
@export var statement: String = ""
@export var variant_type: Variant.Type
@export var defaults: Dictionary = {}

@onready var _panel := $Panel
@onready var _hbox := %HBoxContainer

var param_name_input_pairs: Array
var param_input_strings: Dictionary  # Only loaded from serialized
var spawned_by: ParameterOutput

var _panel_normal: StyleBox
var _panel_focus: StyleBox


func _ready():
	super()

	_panel_normal = _panel.get_theme_stylebox("panel").duplicate()
	_panel_normal.bg_color = color
	_panel_normal.border_color = color.darkened(0.2)

	_panel_focus = _panel.get_theme_stylebox("panel").duplicate()
	_panel_focus.bg_color = color
	_panel_focus.border_color = Constants.FOCUS_BORDER_COLOR

	block_type = Types.BlockType.VALUE
	if not Util.node_is_part_of_edited_scene(self):
		_panel.add_theme_stylebox_override("panel", _panel_normal)

	format()

	if param_input_strings:
		for pair in param_name_input_pairs:
			pair[1].set_raw_input(param_input_strings[pair[0]])


func _on_drag_drop_area_mouse_down():
	_drag_started()


func get_serialized_props() -> Array:
	var props := super()
	if not BlocksCatalog.has_block(block_name):
		props.append_array(serialize_props(["block_format", "statement", "defaults", "variant_type"]))

	var _param_input_strings: Dictionary = {}
	for pair in param_name_input_pairs:
		_param_input_strings[pair[0]] = pair[1].get_raw_input()

	props.append(["param_input_strings", _param_input_strings])

	return props


# Override this method to create custom parameter functionality
func get_parameter_string() -> String:
	var formatted_statement := statement

	for pair in param_name_input_pairs:
		formatted_statement = formatted_statement.replace("{%s}" % pair[0], pair[1].get_string())

	formatted_statement = InstructionTree.IDHandler.make_unique(formatted_statement)

	return formatted_statement


static func get_block_class():
	return "ParameterBlock"


static func get_scene_path():
	return "res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn"


func format():
	param_name_input_pairs = StatementBlock.format_string(self, %HBoxContainer, block_format, defaults)


func _on_focus_entered():
	_panel.add_theme_stylebox_override("panel", _panel_focus)


func _on_focus_exited():
	_panel.add_theme_stylebox_override("panel", _panel_normal)
