@tool
class_name EntryBlock
extends Block

@onready var _top_bar := %TopBar
@onready var _label := %Label


func _ready():
	super()

	_top_bar.color = color
	_label.text = label


func _on_drag_drop_area_mouse_down():
	_drag_started()


func get_scene_path():
	return "res://addons/block_code/ui/blocks/entry_block/entry_block.tscn"
