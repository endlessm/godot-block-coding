@tool
class_name NodeList
extends MarginContainer

signal node_selected(node_data: NodeData)

const NODE_CLASS_LIST: NodeClassList = preload("res://addons/block_code/ui/node_list/node_class_list/all_nodes.tres")

@onready var _nodes := %Nodes
@onready var _node_class_list := %NodeClassList


func _ready():
	$Overlay.visible = false

	for node_class in NODE_CLASS_LIST.node_class_list:
		var node_preview: NodePreview = preload("res://addons/block_code/ui/node_list/node_preview/node_preview.tscn").instantiate()
		node_preview.label = node_class.node_class_name
		node_preview.icon = node_class.preview_icon
		node_preview.clicked.connect(func(): create_node(node_class))
		_node_class_list.add_child(node_preview)


func _on_create_node_pressed():
	$Overlay.visible = true


func create_node(node_class: NodeClass):
	var node_data: NodeData = preload("res://addons/block_code/ui/node_list/node_data/node_data.tscn").instantiate()
	node_data.label = node_class.node_class_name
	node_data.icon = node_class.preview_icon
	node_data.selected.connect(func(): node_selected.emit(node_data))
	%Nodes.add_child(node_data)

	$Overlay.visible = false
