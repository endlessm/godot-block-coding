extends RefCounted

const Types = preload("res://addons/block_code/types/types.gd")
const BlockAST = preload("res://addons/block_code/code_generation/block_ast.gd")

var array: Array[ASTPair]


class ASTPair:
	var ast: BlockAST
	var canvas_position: Vector2

	func _init(p_ast: BlockAST, p_canvas_position: Vector2):
		ast = p_ast
		canvas_position = p_canvas_position


func _init():
	array = []


func append(ast: BlockAST, canvas_position: Vector2):
	array.append(ASTPair.new(ast, canvas_position))


func clear():
	array.clear()


func get_top_level_nodes_of_type(block_type: Types.BlockType) -> Array[BlockAST]:
	var asts: Array[BlockAST] = []

	for ast_pair in array:
		if ast_pair.ast.root.data.type == block_type:
			asts.append(ast_pair.ast)

	return asts
