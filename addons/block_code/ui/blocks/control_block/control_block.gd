@tool
class_name ControlBlock
extends Block

@export var color: Color = Color(1.,1.,1.):
	set = _set_color

@onready var _top_bar := %TopBar
@onready var _middle_bar := %MiddleBar
@onready var _bottom_bar := %BottomBar

func _set_color(new_color: Color) -> void:
	color = new_color
	
	if not is_node_ready():
		return
		
	_top_bar.color = color
	_middle_bar.color = color.darkened(0.2)
	_bottom_bar.color = color

func _ready():
	if Engine.is_editor_hint():
		_set_color(color)


func _on_drag_drop_area_mouse_down():
	_drag_started()
