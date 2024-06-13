@tool
class_name EntryBlock
extends StatementBlock


func _ready():
	super()


func get_scene_path():
	return "res://addons/block_code/ui/blocks/entry_block/entry_block.tscn"


func get_entry_statement() -> String:
	var formatted_statement := statement

	for pair in param_name_input_pairs:
		formatted_statement = formatted_statement.replace("{%s}" % pair[0], pair[1].get_string())

	# One line, should not have \n
	if formatted_statement.find("\n") != -1:
		push_error("Entry block has multiline statement.")

	return formatted_statement
