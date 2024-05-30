@tool
class_name NodePreview
extends MarginContainer

signal clicked

var label: String = ""
var icon: Texture2D

@onready var _label = %Label
@onready var _icon = %Icon


func _ready():
	_label.text = label
	_icon.texture = icon


func _on_button_pressed():
	clicked.emit()
