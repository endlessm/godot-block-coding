extends GutTest
## Tests for CategoryFactory


func get_category_names(categories: Array[BlockCategory]) -> Array[String]:
	var names: Array[String] = []
	for category in categories:
		names.append(category.name)
	return names


func get_class_category_names(_class_name: String) -> Array[String]:
	var blocks: Array[Block] = CategoryFactory.get_inherited_blocks(_class_name)
	return get_category_names(CategoryFactory.get_categories(blocks))


func test_general_category_names():
	var blocks: Array[Block] = CategoryFactory.get_general_blocks()
	var names: Array[String] = get_category_names(CategoryFactory.get_categories(blocks))
	assert_eq(
		names,
		[
			"Lifecycle",
			"Signal",
			"Control",
			"Test",
			"Math",
			"Logic",
			"Variables",
			"Input",
			"Sound",
		]
	)


const class_category_names = [
	["Node2D", ["Movement", "Size", "Graphics"]],
	["Sprite2D", ["Movement", "Size", "Graphics"]],
	["Node", []],
	["Object", []],
]


func test_inherited_category_names(params = use_parameters(class_category_names)):
	assert_eq(get_class_category_names(params[0]), params[1])
