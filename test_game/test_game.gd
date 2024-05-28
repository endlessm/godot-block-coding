extends Node2D

@onready var _test_node := %TestNode

func _ready():
	var script := load("user://test_script.gd")
	_test_node.set_script(script)
	_test_node.set_process(true)
	_test_node.set_physics_process(true)
	
	_test_node.call("_ready")
