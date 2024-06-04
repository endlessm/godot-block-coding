class_name BlockScriptData
extends Resource

@export var script_class_name: String
@export var script_inherits: String
@export var packed_scene: PackedScene


func _init(p_script_class_name: String = "", p_script_inherits: String = "", p_packed_scene: PackedScene = PackedScene.new()):
	script_class_name = p_script_class_name
	script_inherits = p_script_inherits
	packed_scene = p_packed_scene
