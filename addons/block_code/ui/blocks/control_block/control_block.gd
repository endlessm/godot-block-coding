@tool
class_name ControlBlock
extends Block

const Constants = preload("res://addons/block_code/ui/constants.gd")

var arg_name_to_param_input_dict: Dictionary
var args_to_add_after_format: Dictionary  # Only used when loading


func _ready():
	super()

	%TopBackground.color = color
	%TopBackground.shift_bottom = Constants.CONTROL_MARGIN
	%BottomBackground.color = color
	%BottomBackground.shift_top = Constants.CONTROL_MARGIN
	%SnapPoint.add_theme_constant_override("margin_left", Constants.CONTROL_MARGIN)
	%SnapGutter.color = color
	%SnapGutter.custom_minimum_size.x = Constants.CONTROL_MARGIN

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
	return "ControlBlock"


static func get_scene_path():
	return "res://addons/block_code/ui/blocks/control_block/control_block.tscn"


func format():
	arg_name_to_param_input_dict = StatementBlock.format_string(self, %RowHBox, definition.display_template, definition.defaults)
