@tool
class_name BlockCategoryDisplay
extends MarginContainer

signal category_expanded(value: bool)

var category: BlockCategory

@onready var _button := %Button
@onready var _blocks_container := %BlocksContainer
@onready var _blocks := %Blocks
@onready var _background := %Background

@onready var _icon_collapsed := EditorInterface.get_editor_theme().get_icon("GuiTreeArrowRight", "EditorIcons")
@onready var _icon_expanded := EditorInterface.get_editor_theme().get_icon("GuiTreeArrowDown", "EditorIcons")

var expanded: bool:
	set = _set_expanded


func _set_expanded(value: bool):
	expanded = value

	_blocks_container.visible = expanded
	if expanded:
		_button.icon = _icon_expanded
		_background.color = category.color.darkened(0.5)
		_background.color.a = 0.3
	else:
		_button.icon = _icon_collapsed
		_background.color = category.color.darkened(0.2)
		_background.color.a = 0.3

	category_expanded.emit(expanded)


func _ready():
	if not category:
		category = BlockCategory.new()

	_button.text = category.name

	for _block in category.block_list:
		var block: Block = _block as Block

		block.color = category.color

		_blocks.add_child(block)

	expanded = false


func _on_button_toggled(toggled_on):
	expanded = toggled_on
