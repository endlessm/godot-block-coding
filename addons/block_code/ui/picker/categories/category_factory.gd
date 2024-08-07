class_name CategoryFactory
extends Object

const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")
const Types = preload("res://addons/block_code/types/types.gd")
const Util = preload("res://addons/block_code/ui/util.gd")
const Constants = preload("res://addons/block_code/ui/constants.gd")


## Compare block categories for sorting. Compare by order then name.
static func _category_cmp(a: BlockCategory, b: BlockCategory) -> bool:
	if a.order != b.order:
		return a.order < b.order
	return a.name.naturalcasecmp_to(b.name) < 0


static func get_categories(blocks: Array[BlockDefinition], extra_categories: Array[BlockCategory] = []) -> Array[BlockCategory]:
	var cat_map: Dictionary = {}
	var extra_cat_map: Dictionary = {}

	for cat in extra_categories:
		extra_cat_map[cat.name] = cat

	for block in blocks:
		var cat: BlockCategory = cat_map.get(block.category)
		if cat == null:
			cat = extra_cat_map.get(block.category)
			if cat == null:
				var props: Dictionary = Constants.BUILTIN_CATEGORIES_PROPS.get(block.category, {})
				var color: Color = props.get("color", Color.SLATE_GRAY)
				var order: int = props.get("order", 0)
				cat = BlockCategory.new(block.category, color, order)
			cat_map[block.category] = cat
		cat.block_list.append(block)

	# Dictionary.values() returns an untyped Array and there's no way to
	# convert an array type besides Array.assign().
	var cats: Array[BlockCategory] = []
	cats.assign(cat_map.values())
	# Accessing a static Callable from a static function fails in 4.2.1.
	# Use the fully qualified name.
	# https://github.com/godotengine/godot/issues/86032
	cats.sort_custom(CategoryFactory._category_cmp)
	return cats


static func get_general_blocks() -> Array[BlockDefinition]:
	var block: BlockDefinition
	var block_list: Array[BlockDefinition] = []

	BlocksCatalog.setup()

	# Lifecycle
	for block_name in [&"ready", &"process", &"physics_process", &"queue_free"]:
		block = BlocksCatalog.get_block(block_name)
		block_list.append(block)

	# Loops
	for block_name in [&"for", &"while", &"break", &"continue", &"await_scene_ready"]:
		block = BlocksCatalog.get_block(block_name)
		block_list.append(block)

	# Logs
	block = BlocksCatalog.get_block(&"print")
	block_list.append(block)

	# Communication
	for block_name in [&"define_method", &"call_method_group", &"call_method_node"]:
		block = BlocksCatalog.get_block(block_name)
		block_list.append(block)

	for block_name in [&"add_to_group", &"add_node_to_group", &"remove_from_group", &"remove_node_from_group", &"is_in_group", &"is_node_in_group"]:
		block = BlocksCatalog.get_block(block_name)
		block_list.append(block)

	# Variables
	block = BlocksCatalog.get_block(&"vector2")
	block_list.append(block)

	# Math
	for block_name in [&"add", &"subtract", &"multiply", &"divide", &"pow", &"randf_range", &"randi_range", &"sin", &"cos", &"tan"]:
		block = BlocksCatalog.get_block(block_name)
		block_list.append(block)

	# Logic
	for block_name in [&"if", &"else_if", &"else", &"compare", &"and", &"or", &"not"]:
		block = BlocksCatalog.get_block(block_name)
		block_list.append(block)

	# Input
	block = BlocksCatalog.get_block(&"is_input_actioned")
	block_list.append(block)

	# Sounds
	for block_name in [&"load_sound", &"play_sound", &"pause_continue_sound", &"stop_sound"]:
		block = BlocksCatalog.get_block(block_name)
		block_list.append(block)

	# Graphics
	for block_name in [&"viewport_width", &"viewport_height", &"viewport_center"]:
		block = BlocksCatalog.get_block(block_name)
		block_list.append(block)

	return block_list
