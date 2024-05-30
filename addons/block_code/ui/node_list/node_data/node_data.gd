@tool
class_name NodeData
extends MarginContainer

signal selected

var label: String = ""
var icon: Texture2D

var node_selected: bool:
	set = _set_node_selected

@onready var _label = %Label
@onready var _icon = %Icon


func _ready():
	_label.text = label
	_icon.texture = icon
	_set_node_selected(false)


func _set_node_selected(_node_selected):
	node_selected = _node_selected
	$Outline.visible = _node_selected


func deselect():
	_set_node_selected(false)


func _on_select_pressed():
	get_tree().call_group("node_data", "deselect")
	_set_node_selected(true)
	selected.emit()
