@tool
extends MarginContainer

signal create_variable(var_name: String, var_type: String)

@onready var _create_variable_dialog := %CreateVariableDialog


func _on_create_button_pressed():
	_create_variable_dialog.popup()


func _on_create_variable_dialog_create_variable(var_name, var_type):
	create_variable.emit(var_name, var_type)
