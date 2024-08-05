class_name BlockSerializedProperties
extends Resource

# TODO: Remove this class after removing the remaining serialization.

@export var block_class: StringName
@export var serialized_props: Array


func _init(p_block_class: StringName = "", p_serialized_props: Array = []):
	block_class = p_block_class
	serialized_props = p_serialized_props
