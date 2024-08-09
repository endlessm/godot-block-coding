extends Resource

const BlockNameTreeNode = preload("res://addons/block_code/serialization/block_name_tree_node.gd")

@export var name: StringName
@export var children: Array[BlockNameTreeNode]
@export var arguments: Dictionary  # String, ValueBlockNameTreeNode


func _init(p_name: StringName = &"", p_children: Array[BlockNameTreeNode] = [], p_arguments: Dictionary = {}):
	name = p_name
	children = p_children
	arguments = p_arguments
