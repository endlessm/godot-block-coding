@tool
extends "res://addons/block_code/ui/picker/categories/block_category_display.gd"

const Types = preload("res://addons/block_code/types/types.gd")
const VariableDefinition = preload("res://addons/block_code/code_generation/variable_definition.gd")

@onready var h_separator := %HSeparator

signal variable_created(variable: VariableDefinition)


func _ready():
	super()


func _update_blocks():
	super()

	if h_separator:
		h_separator.visible = not block_definitions.is_empty()


func _on_create_variable(var_name, var_type):
	variable_created.emit(VariableDefinition.new(var_name, Types.STRING_TO_VARIANT_TYPE[var_type]))
