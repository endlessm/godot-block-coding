class_name SerializedBlock
extends Resource

@export var block_path: String
@export var serialized_props: Array


func _init(p_block_path: String = "", p_serialized_props: Array = []):
	block_path = p_block_path
	serialized_props = p_serialized_props
