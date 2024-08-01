@tool
extends Window

var script_content: String = ""

@onready var script_label: TextEdit = $Margin/VBox/ColorRect/Scroll/Margin/Code


func _ready():
	popup_centered()
	script_label.text = script_content.replace("\t", "    ")


func _on_copy_code_pressed():
	DisplayServer.clipboard_set(script_content)
