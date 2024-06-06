class_name BlockScriptData
extends Resource

signal source_code_dirty
signal source_code_changed

@export var script_class_name: String:
	set = _set_script_class_name
@export var script_inherits: String:
	set = _set_script_inherits
@export var block_trees: SerializedBlockTreeNodeArray:
	set = _set_block_trees
@export var script_source_code: String


func _init(p_script_class_name: String = "", p_script_inherits: String = "", p_block_trees: SerializedBlockTreeNodeArray = null, p_script_source_code: String = ""):
	script_class_name = p_script_class_name
	script_inherits = p_script_inherits
	block_trees = p_block_trees
	script_source_code = p_script_source_code


func _set_script_class_name(p_script_class_name: String):
	script_class_name = p_script_class_name
	source_code_dirty.emit()


func _set_script_inherits(p_script_inherits: String):
	script_inherits = p_script_inherits
	source_code_dirty.emit()


func _set_block_trees(p_block_trees: SerializedBlockTreeNodeArray):
	block_trees = p_block_trees
	source_code_dirty.emit()
