@tool
class_name SnapPoint
extends MarginContainer

@export var block_path: NodePath

@export var block_type: Types.BlockType = Types.BlockType.EXECUTE

## When block_type is [enum Types.BlockType.VALUE], the type of the value that can be used at this snap point.
@export var variant_type: Variant.Type

signal snapped_block_changed(block: Block)

var block: Block


func _ready():
	if block == null:
		block = get_node_or_null(block_path)


func get_snapped_block() -> Block:
	for node in get_children():
		if node is Block:
			return node
	return null


func has_snapped_block() -> bool:
	return get_snapped_block() != null


func set_snapped_block(snapped_block: Block) -> Block:
	var orphaned_block: Block = _pop_snapped_block()

	if snapped_block:
		add_child(snapped_block)

	if snapped_block and orphaned_block:
		var last_snap = _get_last_snap(snapped_block)
		if last_snap:
			last_snap.set_snapped_block(orphaned_block)
			orphaned_block = null

	snapped_block_changed.emit(snapped_block)

	reset_size()
	block.reset_size()

	return orphaned_block


func remove_snapped_block(snapped_block: Block):
	assert(snapped_block == get_snapped_block())
	set_snapped_block(null)


func _pop_snapped_block() -> Block:
	var snapped_block = get_snapped_block()
	if snapped_block:
		remove_child(snapped_block)
	return snapped_block


func _get_last_snap(block: Block) -> SnapPoint:
	var last_snap: SnapPoint
	while block:
		last_snap = block.bottom_snap
		block = last_snap.get_snapped_block() if last_snap else null
	return last_snap
