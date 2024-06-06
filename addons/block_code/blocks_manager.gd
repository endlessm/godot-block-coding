extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.register_singleton("BlocksManager", self)
	attach_resources()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _attach_script(node: Node, script_source_code: String):
	var script = GDScript.new()
	script.source_code = script_source_code
	script.reload()
	node.set_script(script)
	node._ready()
	await node.is_node_ready()
	node.set_process(true)


func attach_resources():
	for node in get_tree().root.find_children("*", "Node", true, false):
		if not node.has_meta("block_script_data"):
			continue
		var bsd: BlockScriptData = node.get_meta("block_script_data")
		_attach_script(node, bsd.script_source_code)
