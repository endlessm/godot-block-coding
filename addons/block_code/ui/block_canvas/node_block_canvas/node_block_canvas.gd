@tool
class_name NodeBlockCanvas
extends BlockCanvas

var ready_block: EntryBlock
var process_block: EntryBlock


func _ready() -> void:
	ready_block = (
		preload("res://addons/block_code/ui/blocks/entry_block/entry_block.tscn").instantiate()
	)
	ready_block.drag_started.connect(_block_picked)
