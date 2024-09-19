class_name CategoryFactory
extends Object

const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const Constants = preload("res://addons/block_code/ui/constants.gd")


## Returns a list of BlockCategory instances for all block categories.
static func get_all_categories(custom_categories: Array[BlockCategory] = []) -> Array[BlockCategory]:
	var result: Array[BlockCategory]

	for category_name in Constants.BUILTIN_CATEGORIES_PROPS:
		var props: Dictionary = Constants.BUILTIN_CATEGORIES_PROPS.get(category_name, {})
		var color: Color = props.get("color", Color.SLATE_GRAY)
		var order: int = props.get("order", 0)
		result.append(BlockCategory.new(category_name, color, order))

	# TODO: Should we deduplicate custom_categories here?
	result.append_array(custom_categories)

	return result
