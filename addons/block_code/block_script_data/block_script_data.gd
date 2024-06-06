class_name BlockScriptData
extends Resource

@export var script_class_name: String
@export var script_inherits: String
@export var block_trees: SerializedBlockTreeNodeArray
@export var script_source_code: String


func _init(p_script_class_name: String = "", p_script_inherits: String = "", p_block_trees: SerializedBlockTreeNodeArray = null, p_script_source_code: String = ""):
	script_class_name = p_script_class_name
	script_inherits = p_script_inherits
	block_trees = p_block_trees
	script_source_code = p_script_source_code
