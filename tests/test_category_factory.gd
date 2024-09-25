extends GutTest
## Tests for BlockFactory

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")

var block_script: BlockScriptSerialization


func assert_set_eq(set_a: Array, set_b: Array, text: String = ""):
	var set_a_sorted := set_a.duplicate()
	var set_b_sorted := set_b.duplicate()
	set_a_sorted.sort()
	set_b_sorted.sort()
	assert_eq(set_a_sorted, set_b_sorted, text)


func get_category_names(categories: Array[BlockCategory]) -> Array[String]:
	var category_names: Array[String]
	category_names.assign(categories.map(func(category): return category.name))
	category_names.sort()
	return category_names


func get_class_category_names(_class_name: String) -> Array[String]:
	var blocks: Array[BlockDefinition] = BlocksCatalog.get_inherited_blocks(_class_name)
	var categories: Array[BlockCategory] = block_script._categories.filter(func(category): return blocks.any(func(block): return category.name == block.category or category.name == "Variables"))
	return get_category_names(categories)


func before_each():
	block_script = BlockScriptSerialization.new()
	block_script.initialize()


const default_category_names = [
	"Communication | Groups",
	"Communication | Methods",
	"Communication | Nodes",
	"Graphics | Viewport",
	"Input",
	"Lifecycle",
	"Log",
	"Logic | Boolean",
	"Logic | Comparison",
	"Logic | Conditionals",
	"Loops",
	"Math",
	"Sounds",
	"Variables",
]


func test_general_category_names():
	var blocks: Array[BlockDefinition] = block_script.get_available_blocks()
	var names: Array[String] = get_category_names(block_script.get_available_categories())
	assert_set_eq(names, default_category_names)


const class_category_names = [
	["Node2D", ["Transform | Position", "Transform | Rotation", "Transform | Scale", "Graphics | Modulate", "Graphics | Visibility"]],
	["Sprite2D", ["Transform | Position", "Transform | Rotation", "Transform | Scale", "Graphics | Modulate", "Graphics | Visibility"]],
	["Node", []],
	["Object", []],
]


func test_inherited_category_names(params = use_parameters(class_category_names)):
	assert_set_eq(get_class_category_names(params[0]), default_category_names + params[1])


func test_unique_block_names():
	var blocks: Array[BlockDefinition] = block_script.get_available_blocks()
	var block_names: Dictionary
	for block in blocks:
		assert_does_not_have(block_names, block.name, "Block name %s is duplicated" % block.name)
		block_names[block.name] = block
