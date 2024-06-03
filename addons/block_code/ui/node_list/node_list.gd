@tool
class_name NodeList
extends MarginContainer

signal node_selected(node_data: NodeData)

const NODE_CLASS_LIST: NodeClassList = preload("res://addons/block_code/ui/node_list/node_class_list/all_nodes.tres")

var selected_node: NodeData = null

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

	# Check for duplicate name
	var node_name := "New node"
	var new_node_name := node_name
	var count = 1
	var unique := false
	while !unique:
		unique = true

		var nodes := get_nodes()
		for node in nodes:
			if node.node_name == new_node_name:
				new_node_name = node_name + (" (%d)" % count)
				count += 1
				unique = false
				break

	node_data.node_name = new_node_name
	node_data.node_class_name = node_class.node_class_name
	node_data.icon = node_class.preview_icon
	node_data.selected.connect(_node_selected)
	%Nodes.add_child(node_data)

	$Overlay.visible = false


func _node_selected(node_data: NodeData):
	selected_node = node_data
	node_selected.emit(node_data)


func on_node_name_changed(new_node_name: String):
	if selected_node:
		selected_node.set_node_name(new_node_name)


func get_nodes() -> Array[NodeData]:
	var children := %Nodes.get_children()
	var nodes: Array[NodeData] = []
	for c in children:
		if c is NodeData:
			nodes.append(c)

	return nodes
