extends Object

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")
const Types = preload("res://addons/block_code/types/types.gd")
const Constants = preload("res://addons/block_code/ui/constants.gd")
const VariableDefinition = preload("res://addons/block_code/code_generation/variable_definition.gd")

const SCENE_PER_TYPE = {
	Types.BlockType.ENTRY: preload("res://addons/block_code/ui/blocks/entry_block/entry_block.tscn"),
	Types.BlockType.STATEMENT: preload("res://addons/block_code/ui/blocks/statement_block/statement_block.tscn"),
	Types.BlockType.VALUE: preload("res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn"),
	Types.BlockType.CONTROL: preload("res://addons/block_code/ui/blocks/control_block/control_block.tscn"),
}


static func get_category_color(category: String) -> Color:
	var category_props: Dictionary = Constants.BUILTIN_CATEGORIES_PROPS.get(category, {})
	return category_props.get("color", Color.SLATE_GRAY)


static func instantiate_block(block_definition: BlockDefinition) -> Block:
	if block_definition == null:
		push_error("Cannot construct block from null block definition.")
		return null

	var scene = SCENE_PER_TYPE.get(block_definition.type)
	if scene == null:
		push_error("Cannot instantiate Block from type %s" % block_definition.type)
		return null

	var block = scene.instantiate()
	block.definition = block_definition
	return block


static func instantiate_variable_blocks(variables: Array[VariableDefinition]) -> Array[Block]:
	var blocks: Array[Block] = []
	for block_definition in BlocksCatalog.get_variable_block_definitions(variables):
		var block = instantiate_block(block_definition)
		block.color = get_category_color(block_definition.category)
		blocks.append(block)

	return blocks


## Polyfill of Node.is_part_of_edited_scene(), available to GDScript in Godot 4.3+.
static func node_is_part_of_edited_scene(node: Node) -> bool:
	if not Engine.is_editor_hint():
		return false

	var tree := node.get_tree()
	if not tree or not tree.edited_scene_root:
		return false

	var edited_scene_parent := tree.edited_scene_root.get_parent()
	return edited_scene_parent and edited_scene_parent.is_ancestor_of(node)
