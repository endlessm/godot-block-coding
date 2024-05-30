class_name NodeClass
extends Resource

@export var node_class_name: String
@export var scene_ref: PackedScene
@export var preview_icon: Texture2D


func _init(p_node_class_name: String = "", p_scene_ref: PackedScene = null, p_preview_icon: Texture2D = null):
	node_class_name = p_node_class_name
	scene_ref = p_scene_ref
	preview_icon = p_preview_icon
