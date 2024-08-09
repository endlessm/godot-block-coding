@tool
class_name EntryBlock
extends StatementBlock

## if non-empty, this block defines a callback that will be connected to the signal with this name
@export var signal_name: String


func _ready():
	super()
	bottom_snap = null


static func get_block_class():
	return "EntryBlock"


static func get_scene_path():
	return "res://addons/block_code/ui/blocks/entry_block/entry_block.tscn"
