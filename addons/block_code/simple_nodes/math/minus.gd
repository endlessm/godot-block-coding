@tool
class_name Minus
extends Node

func get_class():
	return "Minus"

static func get_custom_blocks() -> Array[BlockCategory]:
	var b: Block

	# Minus
	var minus_list: Array[Block] = []
	b = CategoryFactory.BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "{a: FLOAT} minus {b: FLOAT}"
	b.statement = "return {a} - {b}"
	minus_list.append(b)

	var minus_cat: BlockCategory = BlockCategory.new("Minus", minus_list, Color("45aaf2"))

	return [minus_cat]
