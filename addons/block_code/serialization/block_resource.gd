@tool
class_name BlockResource
extends Resource

@export var block_name: String
@export var block_type: Types.BlockType
@export var variant_type: Variant.Type
@export var block_format: String
@export var statement: String
@export var tooltip_text: String
@export var category: String
@export var defaults: Dictionary
@export var signal_name: String


func _init(
	p_block_name: String = "",
	p_block_type: Types.BlockType = Types.BlockType.STATEMENT,
	p_variant_type: Variant.Type = TYPE_NIL,
	p_block_format: String = "",
	p_statement: String = "",
	p_tooltip_text: String = "",
	p_category: String = "",
	p_defaults = {},
	p_signal_name: String = "",
):
	block_type = p_block_type
	block_format = p_block_format
	statement = p_statement
	tooltip_text = p_tooltip_text
	category = p_category
	defaults = p_defaults
	signal_name = p_signal_name


# Eventually these resources will be replaced with Manuel's


# VERY simple, just use statement no args
func generate_code() -> String:
	return statement
