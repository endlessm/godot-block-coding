@tool
extends MarginContainer

signal create_variable(var_name: String, var_type: String)

@onready var _create_variable_dialog := %CreateVariableDialog
@onready var _create_button := %CreateButton
@onready var _create_variable_icon = _create_button.get_theme_icon("Add", "EditorIcons")


func _ready() -> void:
	_create_button.icon = _create_variable_icon


func _on_create_button_pressed():
	_create_variable_dialog.popup()


func _on_create_variable_dialog_create_variable(var_name, var_type):
	create_variable.emit(var_name, var_type)
