class_name SerializedBlockTreeNode
extends Resource

@export var serialized_block: SerializedBlock
@export var path_child_pairs: Array


func _init(p_serialized_block: SerializedBlock = null, p_path_child_pairs: Array = []):
	serialized_block = p_serialized_block
	path_child_pairs = p_path_child_pairs
