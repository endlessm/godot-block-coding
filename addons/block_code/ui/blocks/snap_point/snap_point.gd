@tool
class_name SnapPoint
extends MarginContainer

@export var block_path: NodePath

var block: Block

func _ready():
	block = get_node(block_path)
