@tool
class_name TitleBar
extends MarginContainer

@onready var _node_name := %NodeName


func node_selected(node_data: NodeData):
	_node_name.text = node_data.label
