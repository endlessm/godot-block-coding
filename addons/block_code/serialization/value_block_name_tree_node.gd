class_name ValueBlockNameTreeNode
extends Resource

@export var block_name: String
@export var arguments: Dictionary  # String, ValueBlockNameTreeNode


func _init(p_block_name: String = "", p_arguments: Dictionary = {}):
	block_name = p_block_name
	arguments = p_arguments
