extends Resource

const BlockSerialization = preload("res://addons/block_code/serialization/block_serialization.gd")

@export var root: BlockSerialization
@export var canvas_position: Vector2


func _init(p_root: BlockSerialization = null, p_canvas_position: Vector2 = Vector2(0, 0)):
	root = p_root
	canvas_position = p_canvas_position


func _to_string():
	return to_string_recursive(root, 0)


func to_string_recursive(node: BlockSerialization, depth: int) -> String:
	var string: String = "%s %s\n" % ["-".repeat(depth), node.block_name]

	for c in node.children:
		string += to_string_recursive(c, depth + 1)

	return string
