@tool
class_name SimpleCharacter
extends CharacterBody2D

var sprite_texture: Texture2D = preload("res://icon.svg")


func _ready():
	$Sprite2D.texture = sprite_texture


func get_exposed_properties() -> Array[String]:
	return ["position"]


func get_custom_blocks() -> Array[Block]:
	return []
