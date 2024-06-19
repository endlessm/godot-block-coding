class_name OptionData
extends Resource

@export var selected: int
@export var items: Array


func _init(p_items: Array = [], p_selected: int = 0):
	items = p_items
	selected = p_selected
