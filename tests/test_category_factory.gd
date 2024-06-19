extends GutTest
## Tests for CategoryFactory


func get_category_names(categories: Array[BlockCategory]) -> Array[String]:
	var names: Array[String] = []
	for category in categories:
		names.append(category.name)
	return names


func get_class_category_names(_class_name: String) -> Array[String]:
	return get_category_names(CategoryFactory.get_inherited_categories(_class_name))


func test_general_category_names():
	var names: Array[String] = get_category_names(CategoryFactory.get_general_categories())
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
	["Node2D", ["Node2D", "CanvasItem"]],
	["Sprite2D", ["Node2D", "CanvasItem"]],
	["Node", []],
	["Object", []],
]


func test_inherited_category_names(params = use_parameters(class_category_names)):
	assert_eq(get_class_category_names(params[0]), params[1])
