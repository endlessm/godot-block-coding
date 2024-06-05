class_name BlockScriptData
extends Resource

@export var script_class_name: String
@export var script_inherits: String
@export var block_trees: SerializedBlockTreeNodeArray


func _init(p_script_class_name: String = "", p_script_inherits: String = "", p_block_trees: SerializedBlockTreeNodeArray = null):
	script_class_name = p_script_class_name
	script_inherits = p_script_inherits
	block_trees = p_block_trees
