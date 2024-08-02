@tool
class_name EntryBlock
extends StatementBlock

## if non-empty, this block defines a callback that will be connected to the signal with this name
@export var signal_name: String


func _ready():
	block_type = Types.BlockType.ENTRY
	super()


static func get_block_class():
	return "EntryBlock"


static func get_scene_path():
	return "res://addons/block_code/ui/blocks/entry_block/entry_block.tscn"


func get_entry_statement() -> String:
	var formatted_statement := statement

	for pair in param_name_input_pairs:
		formatted_statement = formatted_statement.replace("{%s}" % pair[0], pair[1].get_string())

	return formatted_statement


func get_serialized_props() -> Array:
	var props := super()
	if not BlocksCatalog.has_block(block_name):
		props.append_array(serialize_props(["signal_name"]))
	return props
