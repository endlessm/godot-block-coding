class_name BlockScriptData
extends Resource

@export var script_inherits: String
@export var block_trees: SerializedBlockTreeNodeArray
@export var generated_script: String


func _init(p_script_inherits: String = "", p_block_trees: SerializedBlockTreeNodeArray = null, p_generated_script: String = ""):
	script_inherits = p_script_inherits
	block_trees = p_block_trees
	generated_script = p_generated_script
