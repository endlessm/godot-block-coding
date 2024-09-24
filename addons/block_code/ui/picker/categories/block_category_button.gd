@tool
extends MarginContainer

const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const Util = preload("res://addons/block_code/ui/util.gd")

signal selected

var category: BlockCategory

@onready var _panel := %Panel
@onready var _label := %Label


func _ready():
	if not category:
		category = BlockCategory.new("Example", Color.RED)

	if not Util.node_is_part_of_edited_scene(self):
		var new_stylebox: StyleBoxFlat = _panel.get_theme_stylebox("panel").duplicate()
		new_stylebox.bg_color = category.color
		_panel.add_theme_stylebox_override("panel", new_stylebox)

	_label.text = category.name


func _on_button_pressed():
	selected.emit()
