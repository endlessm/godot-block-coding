@tool
class_name CollapsableSettings
extends HBoxContainer

@onready var _expand_button: Button = %ExpandSettingsButton
@onready var _collapse_button: Button = %CollapseSettingsButton
var _collapsed := false


func _ready() -> void:
	_collapse()
	move_child(_expand_button, 0)
	move_child(_collapse_button, -1)
	_expand_button.connect("button_up", _expand)
	_collapse_button.connect("button_up", _collapse)


func _expand() -> void:
	if not _collapsed:
		return
	for child in get_children(true):
		child.visible = true
	_expand_button.visible = false
	_collapse_button.visible = true
	_collapsed = false


func _collapse() -> void:
	if _collapsed:
		return
	for child in get_children(true):
		child.visible = false
	_expand_button.visible = true
	_collapsed = true
