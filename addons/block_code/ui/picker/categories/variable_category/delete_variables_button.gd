@tool
extends MarginContainer

signal delete_variables(variables: Array[String])

@onready var _delete_variables_dialog := %DeleteVariablesDialog
@onready var _delete_button := %DeleteButton
@onready var _delete_variables_icon = _delete_button.get_theme_icon("Remove", "EditorIcons")


func _ready() -> void:
	_delete_button.icon = _delete_variables_icon


func _on_delete_button_pressed():
	_delete_variables_dialog.popup()


func _on_delete_variables_dialog_delete_variables(variables):
	delete_variables.emit(variables)
