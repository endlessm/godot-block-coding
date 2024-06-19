@tool
class_name Pong
extends Node2D


func get_custom_class():
	return "Pong"


static func get_custom_categories() -> Array[BlockCategory]:
	return [BlockCategory.new("Scoring", Color("4a86d5"))]


static func get_custom_blocks() -> Array[Block]:
	var b: Block
	var block_list: Array[Block] = []

	# TODO: Only for testing. Move these blocks where they belong.
	b = CategoryFactory.BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Set player 1 score to {score: INT}"
	b.statement = 'get_tree().call_group("hud", "set_player_score", "right", {score})'
	b.category = "Scoring"
	block_list.append(b)

	b = CategoryFactory.BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Set player 2 score to {score: INT}"
	b.statement = 'get_tree().call_group("hud", "set_player_score", "left", {score})'
	b.category = "Scoring"
	block_list.append(b)

	return block_list
