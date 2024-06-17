@tool
class_name Plus
extends Node

func get_class():
	return "Plus"

static func get_custom_blocks() -> Array[BlockCategory]:
	var b: Block

	# Plus
	var plus_list: Array[Block] = []
	b = CategoryFactory.BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "{a: FLOAT} plus {b: FLOAT}"
	b.statement = "return {a} + {b}"
	plus_list.append(b)

	var plus_cat: BlockCategory = BlockCategory.new("Plus", plus_list, Color("45aaf2"))

	return [plus_cat]
