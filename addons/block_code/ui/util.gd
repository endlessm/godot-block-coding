extends Object

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")
const Types = preload("res://addons/block_code/types/types.gd")

const SCENE_PER_TYPE = {
	Types.BlockType.ENTRY: preload("res://addons/block_code/ui/blocks/entry_block/entry_block.tscn"),
	Types.BlockType.STATEMENT: preload("res://addons/block_code/ui/blocks/statement_block/statement_block.tscn"),
	Types.BlockType.CONTROL: preload("res://addons/block_code/ui/blocks/control_block/control_block.tscn"),
}


static func instantiate_block(block_name: StringName) -> Block:
	BlocksCatalog.setup()
	var block_definition: BlockDefinition = BlocksCatalog.get_block(block_name)
	if block_definition == null:
		push_error("The block %s is not in the catalog yet!" % block_name)
		return

	var scene = SCENE_PER_TYPE[block_definition.type]
	var b = scene.instantiate()
	b.block_name = block_definition.name
	if block_definition.type == Types.BlockType.CONTROL:
		b.block_formats = [block_definition.display_template]
		b.statements = [block_definition.code_template]
	else:
		b.block_format = block_definition.display_template
		b.statement = block_definition.code_template
	b.defaults = block_definition.defaults
	b.tooltip_text = block_definition.description
	b.category = block_definition.category
	if block_definition.type == Types.BlockType.ENTRY and block_definition.signal_name != "":
		b.signal_name = block_definition.signal_name
	return b


## Polyfill of Node.is_part_of_edited_scene(), available to GDScript in Godot 4.3+.
static func node_is_part_of_edited_scene(node: Node) -> bool:
	if not Engine.is_editor_hint():
		return false

	var tree := node.get_tree()
	if not tree or not tree.edited_scene_root:
		return false

	var edited_scene_parent := tree.edited_scene_root.get_parent()
	return edited_scene_parent and edited_scene_parent.is_ancestor_of(node)
