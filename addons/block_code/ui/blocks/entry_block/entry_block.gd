@tool
class_name EntryBlock
extends StatementBlock


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
