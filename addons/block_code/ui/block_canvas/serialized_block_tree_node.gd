class_name SerializedBlockTreeNode
extends Resource

@export var name: StringName
@export var position: Vector2
@export var path_child_pairs: Array

# TODO: Remove once the data/UI decouple is done.
@export var serialized_block: SerializedBlock


func _init(p_name: StringName, p_position: Vector2 = Vector2.ZERO, p_serialized_block: SerializedBlock = null, p_path_child_pairs: Array = []):
	name = p_name
	position = p_position
	serialized_block = p_serialized_block
	path_child_pairs = p_path_child_pairs
