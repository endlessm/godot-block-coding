@tool
class_name SnapPoint
extends MarginContainer

@export var block_path: NodePath

@export var block_type: Types.BlockType = Types.BlockType.EXECUTE

@export var snapped_block: Block:
	get:
		return snapped_block
	set(value):
		if value != snapped_block:
			var old_block = snapped_block
			snapped_block = value
			snapped_block_changed.emit(snapped_block)
			if value == null and old_block:
				snapped_block_removed.emit(old_block)

## When block_type is [enum Types.BlockType.VALUE], the type of the value that can be used at this snap point.
@export var variant_type: Variant.Type

signal drag_started(block: Block)
signal snapped_block_changed(block: Block)
signal snapped_block_removed(block: Block)

var block: Block


func _ready():
	if block == null:
		block = get_node_or_null(block_path)
	_update_snapped_block_from_children()


func _update_snapped_block_from_children():
	# Temporary migration to set the snapped_block property based on children
	# of this node.
	if snapped_block:
		return
	for node in get_children():
		var block = node as Block
		if block:
			snapped_block = block
			return


func get_snapped_block() -> Block:
	return snapped_block


func has_snapped_block() -> bool:
	return snapped_block != null


func insert_snapped_block(new_block: Block) -> Block:
	var old_block = get_snapped_block()

	if old_block:
		remove_child(old_block)

	if new_block:
		add_child(new_block)

	if new_block and old_block:
		var last_snap = _get_last_snap(new_block)
		if last_snap:
			old_block = last_snap.insert_snapped_block(old_block)

	return old_block


func _get_last_snap(block: Block) -> SnapPoint:
	var last_snap: SnapPoint
	while block:
		last_snap = block.bottom_snap
		block = last_snap.get_snapped_block() if last_snap else null
	return last_snap


func _on_child_entered_tree(node):
	var block = node as Block
	if not block:
		return
	if block == snapped_block:
		return
	if snapped_block:
		# We only allow a single snapped block at a time
		push_warning("Attempted to add more than one Block node ({block}) to the same SnapPoint ({snap_point})".format({"block": block, "snap_point": self}))
		call_deferred("remove_child", snapped_block)
	snapped_block = block


func _on_child_exiting_tree(node):
	var block = node as Block
	if block and block == snapped_block:
		snapped_block = null
