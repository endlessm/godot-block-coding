class_name BlockEditorContext
extends Object

signal changed

static var _instance: BlockEditorContext

var block_code_node: BlockCode:
	set(value):
		block_code_node = value
		changed.emit()

var block_script: BlockScriptSerialization:
	get:
		if block_code_node == null:
			return null
		return block_code_node.block_script

var parent_node: Node:
	get:
		if block_code_node == null:
			return null
		return block_code_node.get_parent()


func force_update() -> void:
	changed.emit()


static func get_default() -> BlockEditorContext:
	if _instance == null:
		_instance = BlockEditorContext.new()
	return _instance
