@tool
class_name NodeData
extends MarginContainer

signal selected(me: NodeData)

var node_name: String = "":
	set = set_node_name

var node_class_name: String = ""
var icon: Texture2D

var node_selected: bool:
	set = _set_node_selected

@onready var _label = %Label
@onready var _icon = %Icon


func _ready():
	_icon.texture = icon
	set_node_name(node_name)
	_set_node_selected(false)


func _set_node_selected(_node_selected):
	node_selected = _node_selected
	$Outline.visible = _node_selected


func set_node_name(new_node_name: String):
	node_name = new_node_name

	if is_node_ready():
		_label.text = node_name


func deselect():
	_set_node_selected(false)


func _on_select_pressed():
	get_tree().call_group("node_data", "deselect")
	_set_node_selected(true)
	selected.emit(self)
