extends GutTest
## Tests for BlockFactory

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")

var block_script: BlockScriptSerialization


func get_category_names(categories: Array[BlockCategory]) -> Array[String]:
	var categories_sorted: Array[BlockCategory]
	categories_sorted.assign(categories)
	categories_sorted.sort_custom(BlockCategory.sort_by_order)
	var result: Array[String]
	result.assign(categories_sorted.map(func(category): return category.name))
	return result


func get_class_category_names(_class_name: String) -> Array[String]:
	var blocks: Array[BlockDefinition] = BlocksCatalog.get_inherited_blocks(_class_name)
	var categories: Array[BlockCategory] = block_script._categories.filter(func(category): return blocks.any(func(block): return block.category == category.name))
	return get_category_names(categories)


func before_each():
	block_script = BlockScriptSerialization.new()
	block_script.initialize()


func test_general_category_names():
	var blocks: Array[BlockDefinition] = block_script.get_available_blocks()
	var names: Array[String] = get_category_names(block_script.get_available_categories())
	assert_eq(
		names,
		[
			"Lifecycle",
			"Graphics | Viewport",
			"Sounds",
			"Input",
			"Communication | Methods",
			"Communication | Groups",
			"Loops",
			"Logic | Conditionals",
			"Logic | Comparison",
			"Logic | Boolean",
			"Variables",
			"Math",
			"Log",
		]
	)


const class_category_names = [
	["Node2D", ["Transform | Position", "Transform | Rotation", "Transform | Scale", "Graphics | Modulate", "Graphics | Visibility"]],
	["Sprite2D", ["Transform | Position", "Transform | Rotation", "Transform | Scale", "Graphics | Modulate", "Graphics | Visibility"]],
	["Node", []],
	["Object", []],
]


func test_inherited_category_names(params = use_parameters(class_category_names)):
	assert_eq(get_class_category_names(params[0]), params[1])


func test_unique_block_names():
	var blocks: Array[BlockDefinition] = block_script.get_available_blocks()
	var block_names: Dictionary
	for block in blocks:
		assert_does_not_have(block_names, block.name, "Block name %s is duplicated" % block.name)
		block_names[block.name] = block
