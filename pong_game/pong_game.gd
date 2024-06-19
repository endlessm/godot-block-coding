@tool
class_name Pong
extends Node2D


func get_custom_class():
	return "Pong"


static func get_custom_blocks() -> Array[BlockCategory]:
	var b: Block

	# TODO: Only for testing. Move these blocks where they belong.
	var score_list: Array[Block] = []
	b = CategoryFactory.BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Change player 1 score by {score: INT}"
	b.statement = 'get_tree().call_group("hud", "set_player_score", "right", {score})'
	score_list.append(b)

	b = CategoryFactory.BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Change player 2 score by {score: INT}"
	b.statement = 'get_tree().call_group("hud", "set_player_score", "left", {score})'
	score_list.append(b)

	var score_category: BlockCategory = BlockCategory.new("Scoring", score_list, Color("4a86d5"))

	return [score_category]
