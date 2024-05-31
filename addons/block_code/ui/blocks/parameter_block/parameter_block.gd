@tool
class_name ParameterBlock
extends Block

@export var label: String = "Parameter":
	set = _set_label

@onready var _panel := $Panel
@onready var _label := %Label


func _set_label(new_label: String) -> void:
	label = new_label

	if not is_node_ready():
		return

	_label.text = label


func _ready():
	super()

	_panel.get_theme_stylebox("panel").bg_color = color

	_set_label(label)


func _on_drag_drop_area_mouse_down():
	_drag_started()


# Override this method to create custom parameter functionality
func get_parameter_string() -> String:
	var str: String = ""

	# Nested stuff

	return str
