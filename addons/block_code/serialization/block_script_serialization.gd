@tool
class_name BlockScriptSerialization
extends Resource

const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")
const BlockCategory = preload("res://addons/block_code/ui/picker/categories/block_category.gd")
const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlockSerializationTree = preload("res://addons/block_code/serialization/block_serialization_tree.gd")
const VariableDefinition = preload("res://addons/block_code/code_generation/variable_definition.gd")

@export var script_inherits: String
@export var block_serialization_trees: Array[BlockSerializationTree]
@export var variables: Array[VariableDefinition]
@export var generated_script: String
@export var version: int


func _init(
	p_script_inherits: String = "", p_block_serialization_trees: Array[BlockSerializationTree] = [], p_variables: Array[VariableDefinition] = [], p_generated_script: String = "", p_version = 0
):
	script_inherits = p_script_inherits
	block_serialization_trees = p_block_serialization_trees
	generated_script = p_generated_script
	variables = p_variables
	version = p_version


func get_definitions() -> Array[BlockDefinition]:
	for class_dict in ProjectSettings.get_global_class_list():
		if class_dict.class == script_inherits:
			var script = load(class_dict.path)
			if script.has_method("setup_custom_blocks"):
				script.setup_custom_blocks()
			break

	return BlocksCatalog.get_inherited_blocks(script_inherits)


func get_categories() -> Array[BlockCategory]:
	for class_dict in ProjectSettings.get_global_class_list():
		if class_dict.class == script_inherits:
			var script = load(class_dict.path)
			if script.has_method("get_custom_categories"):
				return script.get_custom_categories()

	return []
