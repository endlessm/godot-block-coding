@tool
class_name BlockCategoryButton
extends MarginContainer

signal selected

var category: BlockCategory

@onready var _panel := %Panel
@onready var _label := %Label


func _ready():
	if not category:
		category = BlockCategory.new("Example", Color.RED)

	var new_stylebox: StyleBoxFlat = _panel.get_theme_stylebox("panel").duplicate()
	new_stylebox.bg_color = category.color

	_panel.add_theme_stylebox_override("panel", new_stylebox)

	_label.text = category.name


func _on_button_pressed():
	selected.emit(category)
