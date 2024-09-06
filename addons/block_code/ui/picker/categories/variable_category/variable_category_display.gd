@tool
extends "res://addons/block_code/ui/picker/categories/block_category_display.gd"

const Types = preload("res://addons/block_code/types/types.gd")
const VariableDefinition = preload("res://addons/block_code/code_generation/variable_definition.gd")

signal variable_created(variable: VariableDefinition)

@onready var variable_blocks := %VariableBlocks


func _ready():
	super()


func _on_create_variable(var_name, var_type):
	variable_created.emit(VariableDefinition.new(var_name, Types.STRING_TO_VARIANT_TYPE[var_type]))
