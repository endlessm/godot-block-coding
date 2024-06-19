@tool
class_name PrintBlock
extends StatementBlock


func _init():
	var _block = load(StatementBlock.get_scene_path()).instantiate() as Node
	_block.replace_by(self, true)
	block_name = _block.block_name
	label = _block.label
	color = _block.color
	block_type = _block.block_type
	bottom_snap_path = _block.bottom_snap_path
	_block.queue_free()

	block_name = "print_block"
	block_format = "print {text: STRING}"
	statement = "print({text})"
	color = Color("9989df")


func copy_block():
	return PrintBlock.new()


static func get_block_class():
	return "PrintBlock"


static func get_scene_path():
	return "res://addons/block_code/ui/picker/categories/print_block.gd"


# Strip out properties that never change for this block type
func get_serialized_props() -> Array:
	var props = super()
	return props.filter(func(prop): return prop[0] not in ["block_name", "label", "color", "block_type", "block_format", "statement"])
