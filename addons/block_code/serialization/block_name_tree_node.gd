class_name BlockNameTreeNode
extends Resource

@export var block_name: String
@export var children: Array[BlockNameTreeNode]
@export var arguments: Dictionary  # String, ValueBlockNameTreeNode


func _init(p_block_name: String = "", p_children: Array[BlockNameTreeNode] = [], p_arguments: Dictionary = {}):
	block_name = p_block_name
	children = p_children
	arguments = p_arguments
