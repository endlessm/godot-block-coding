class_name BlockScriptSerialization
extends Resource

const BlockSerializationTree = preload("res://addons/block_code/serialization/block_serialization_tree.gd")

@export var script_inherits: String
@export var block_serialization_trees: Array[BlockSerializationTree]
@export var variables: Array[VariableResource]
@export var generated_script: String
@export var version: int


func _init(p_script_inherits: String = "", p_block_serialization_trees: Array[BlockSerializationTree] = [], p_variables: Array[VariableResource] = [], p_generated_script: String = "", p_version = 0):
	script_inherits = p_script_inherits
	block_serialization_trees = p_block_serialization_trees
	generated_script = p_generated_script
	variables = p_variables
	version = p_version
