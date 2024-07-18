@tool
class_name ParameterBlock
extends Block

const Util = preload("res://addons/block_code/ui/util.gd")

@onready var _panel := $Panel
@onready var _hbox := %HBoxContainer

var arg_name_to_param_input_dict: Dictionary
var args_to_add_after_format: Dictionary  # Only used when loading
var spawned_by: ParameterOutput


func _ready():
	super()

	block_resource.block_type = Types.BlockType.VALUE
	if not Util.node_is_part_of_edited_scene(self):
		var new_panel = _panel.get_theme_stylebox("panel").duplicate()
		new_panel.bg_color = color
		new_panel.border_color = color.darkened(0.2)
		_panel.add_theme_stylebox_override("panel", new_panel)

	format()

	for arg_name in arg_name_to_param_input_dict:
		if arg_name in args_to_add_after_format:
			var argument = args_to_add_after_format[arg_name]
			if argument is Block:
				arg_name_to_param_input_dict[arg_name].snap_point.add_child(argument)
			else:
				arg_name_to_param_input_dict[arg_name].set_raw_input(argument)


func _on_drag_drop_area_mouse_down():
	_drag_started()


static func get_block_class():
	return "ParameterBlock"


static func get_scene_path():
	return "res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn"


func format():
	arg_name_to_param_input_dict = StatementBlock.format_string(self, %HBoxContainer, block_resource.block_format, block_resource.defaults)
