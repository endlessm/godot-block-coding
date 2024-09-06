extends Resource

const BlockSerialization = preload("res://addons/block_code/serialization/block_serialization.gd")

@export var name: StringName
@export var children: Array[BlockSerialization]
@export var arguments: Dictionary  # String, ValueBlockSerialization


func _init(p_name: StringName = &"", p_children: Array[BlockSerialization] = [], p_arguments: Dictionary = {}):
	name = p_name
	children = p_children
	arguments = p_arguments
