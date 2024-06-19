@tool
class_name ReadyBlock
extends EntryBlock


func _init():
	var _block = load(EntryBlock.get_scene_path()).instantiate() as Node
	_block.replace_by(self, true)
	block_name = _block.block_name
	label = _block.label
	color = _block.color
	block_type = _block.block_type
	bottom_snap_path = _block.bottom_snap_path
	_block.queue_free()

	block_name = "ready_block"
	block_format = "On Ready"
	statement = "func _ready():"
	color = Color("fa5956")


func copy_block():
	return ReadyBlock.new()


static func get_block_class():
	return "ReadyBlock"


static func get_scene_path():
	return "res://addons/block_code/ui/picker/categories/ready_block.gd"


# Strip out properties that never change for this block type
func get_serialized_props() -> Array:
	var props = super()
	return props.filter(func(prop): return prop[0] not in ["block_name", "label", "color", "block_type", "block_format", "statement"])
