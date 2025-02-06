@tool
extends MarginContainer

const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const Util = preload("res://addons/block_code/ui/util.gd")

signal selected

var category: BlockCategory

@onready var _panel := %Panel
@onready var _button := %Button


func _ready():
	if not category:
		category = BlockCategory.new("Example", Color.RED)
	var category_title = category.name.get_slice(" |", 0)

	if not self.is_part_of_edited_scene():
		var texture = load("res://addons/block_code/ui/picker/categories/icons/" + category_title.to_lower() + ".svg")
		_button.icon = texture
		_panel.modulate = category.color

	_button.tooltip_text = tr(category_title)


func _on_button_pressed():
	selected.emit()
