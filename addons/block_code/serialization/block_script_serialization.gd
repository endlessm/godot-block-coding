class_name BlockScriptSerialization
extends Resource

@export var script_inherits: String
@export var block_trees: Array[BlockSerialization]
@export var variables: Array[VariableResource]
@export var generated_script: String
@export var version: int


func _init(p_script_inherits: String = "", p_block_trees: Array[BlockSerialization] = [], p_variables: Array[VariableResource] = [], p_generated_script: String = "", p_version = 0):
	script_inherits = p_script_inherits
	block_trees = p_block_trees
	generated_script = p_generated_script
	variables = p_variables
	version = p_version
