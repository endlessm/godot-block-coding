@tool
class_name BasicBlock
extends Block

@onready var _top_bar := %TopBar
@onready var _label := %Label


func _ready():
	super()

	_top_bar.color = color
	_label.text = label


func _on_drag_drop_area_mouse_down():
	_drag_started()


static func get_block_class():
	return "BasicBlock"


static func get_scene_path():
	return "res://addons/block_code/ui/blocks/basic_block/basic_block.tscn"
