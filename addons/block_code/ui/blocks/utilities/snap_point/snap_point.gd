@tool
class_name SnapPoint
extends MarginContainer

@export var block_path: NodePath

@export var block_type: Types.BlockType = Types.BlockType.STATEMENT

var block: Block


func _ready():
	if block == null:
		block = get_node_or_null(block_path)


func get_snapped_block() -> Block:
	if get_child_count() == 0:
		return null

	return get_child(0) as Block
