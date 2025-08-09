@tool
extends ConfirmationDialog

const BlockCategoryDisplay = preload("res://addons/block_code/ui/picker/categories/block_category_display.gd")

signal delete_variables(variables: Array[String])

@onready var _variables_container := %VariablesContainer
var _checkbox_template := CheckBox.new()
var _main_panel: Node


func _ready():
	_main_panel = get_parent()


func _on_confirmed():
	var variables := []
	for checkbox in _variables_container.get_children():
		if checkbox.button_pressed:
			variables.append(checkbox.text)

	delete_variables.emit(variables)

	hide()


func _on_about_to_popup() -> void:
	for checkbox in _variables_container.get_children():
		_variables_container.remove_child(checkbox)
		checkbox.queue_free()

	while _main_panel.name != "MainPanel":
		_main_panel = _main_panel.get_parent()

	for variable in _main_panel._context.block_script.variables:
		_checkbox_template.text = variable.var_name
		_variables_container.add_child(_checkbox_template.duplicate())
