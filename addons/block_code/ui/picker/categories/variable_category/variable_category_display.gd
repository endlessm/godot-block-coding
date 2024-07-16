@tool
class_name VariableCategoryDisplay
extends BlockCategoryDisplay

signal variable_created(variable: VariableResource)

@onready var variable_blocks := %VariableBlocks


func _ready():
	super()


func _on_create_variable(var_name, var_type):
	variable_created.emit(VariableResource.new(var_name, Types.STRING_TO_VARIANT_TYPE[var_type]))
