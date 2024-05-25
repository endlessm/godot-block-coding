@tool
class_name SnapPoint
extends MarginContainer

@export var block_path: NodePath

var block: Block

func _ready():
	block = get_node(block_path)

func get_snapped_block() -> Block:
	if get_child_count() == 0:
		return null
	else:
		return get_child(0) as Block
