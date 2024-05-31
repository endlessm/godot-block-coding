class_name CategoryFactory
extends Object

const BLOCKS: Dictionary = {
	"control_block": preload("res://addons/block_code/ui/blocks/control_block/control_block.tscn"),
	"basic_block": preload("res://addons/block_code/ui/blocks/basic_block/basic_block.tscn"),
	"simple_text_block": preload("res://addons/block_code/ui/blocks/simple_text_block/simple_text_block.tscn"),
	"parameter_block": preload("res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn"),
	"simple_parameter_block": preload("res://addons/block_code/ui/custom_blocks/simple_parameter_block/simple_parameter_block.tscn")
}


static func get_general_categories() -> Array[BlockCategory]:
	var categories: Array[BlockCategory] = []

	var b: Block

	# Entry
	var entry_list: Array[Block] = []
	b = BLOCKS["basic_block"].instantiate()
	b.block_name = "ready_block"
	b.label = "On Ready"
	b.block_type = Types.BlockType.ENTRY
	entry_list.append(b)

	b = BLOCKS["basic_block"].instantiate()
	b.block_name = "process_block"
	b.label = "On Process"
	entry_list.append(b)

	var entry_cat: BlockCategory = BlockCategory.new("Entry", Color("fa5956"), entry_list)

	# Test
	var test_list: Array[Block] = []
	b = BLOCKS["simple_text_block"].instantiate()
	b.text = 'print("hi")'
	b.label = 'print "hi"'
	test_list.append(b)

	b = BLOCKS["control_block"].instantiate()
	b.label = "repeat 10 times"
	test_list.append(b)

	b = BLOCKS["parameter_block"].instantiate()
	test_list.append(b)

	b = BLOCKS["simple_parameter_block"].instantiate()
	test_list.append(b)

	var test_cat: BlockCategory = BlockCategory.new("Test", Color("9989df"), test_list)

	return [entry_cat, test_cat]
