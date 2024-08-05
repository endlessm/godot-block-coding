class_name BlockSerialization
extends Resource

@export var name: StringName
@export var position: Vector2
@export var path_child_pairs: Array

# TODO: Remove once the data/UI decouple is done.
@export var block_serialized_properties: BlockSerializedProperties


func _init(p_name: StringName, p_position: Vector2 = Vector2.ZERO, p_block_serialized_properties: BlockSerializedProperties = null, p_path_child_pairs: Array = []):
	name = p_name
	position = p_position
	block_serialized_properties = p_block_serialized_properties
	path_child_pairs = p_path_child_pairs
