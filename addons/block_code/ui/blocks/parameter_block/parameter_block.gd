@tool
class_name ParameterBlock
extends Block

@onready var _panel := $Panel
@onready var _label := %Label


func _ready():
	super()

	_panel.get_theme_stylebox("panel").bg_color = color

	_label.text = label


func _on_drag_drop_area_mouse_down():
	_drag_started()


# Override this method to create custom parameter functionality
func get_parameter_string() -> String:
	var str: String = ""

	# Nested stuff

	return str


func get_scene_path():
	return "res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn"
