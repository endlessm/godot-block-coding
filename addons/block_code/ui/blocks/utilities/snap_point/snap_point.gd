@tool
class_name SnapPoint
extends MarginContainer

const Types = preload("res://addons/block_code/types/types.gd")

@export var block_type: Types.BlockType = Types.BlockType.STATEMENT

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


func _ready():
	_update_snapped_block_from_children()


func _update_snapped_block_from_children():
	# Temporary migration to set the snapped_block property based on children
	# of this node.
	if snapped_block:
		return
	for node in get_children():
		var child_block = node as Block
		if child_block:
			snapped_block = child_block
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


func _get_last_snap(next_block: Block) -> SnapPoint:
	var last_snap: SnapPoint
	while next_block:
		last_snap = next_block.bottom_snap
		next_block = last_snap.get_snapped_block() if last_snap else null
	return last_snap


func _on_child_entered_tree(node):
	var new_block = node as Block
	if not new_block:
		return
	if new_block == snapped_block:
		return
	if snapped_block:
		# We only allow a single snapped block at a time
		push_warning("Attempted to add more than one Block node ({block}) to the same SnapPoint ({snap_point})".format({"block": new_block, "snap_point": self}))
		remove_child.call_deferred(snapped_block)
	snapped_block = new_block


func _on_child_exiting_tree(node):
	var old_block = node as Block
	if old_block and old_block == snapped_block:
		snapped_block = null
