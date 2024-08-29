@tool

extends Resource

const Types = preload("res://addons/block_code/types/types.gd")

@export var name: StringName

## The target node. Leaving this empty the block is considered a general block
## (for any node).
@export var target_node_class: String

@export_multiline var description: String
@export var category: String

@export var type: Types.BlockType
@export var variant_type: Variant.Type

@export var display_template: String
@export_multiline var code_template: String
@export var defaults: Dictionary

## Only for blocks of type Types.ENTRY. If non-empty, this block defines a
## callback that will be connected to the signal with this name.
@export var signal_name: String

## Empty except for blocks that have a defined scope
@export var scope: String

@export var extension_script: GDScript

var _extension: BlockExtension:
	get:
		if _extension == null and extension_script and extension_script.can_instantiate():
			_extension = extension_script.new()
		return _extension as BlockExtension


func _init(
	p_name: StringName = &"",
	p_target_node_class = "",
	p_description: String = "",
	p_category: String = "",
	p_type: Types.BlockType = Types.BlockType.STATEMENT,
	p_variant_type: Variant.Type = TYPE_NIL,
	p_display_template: String = "",
	p_code_template: String = "",
	p_defaults = {},
	p_signal_name: String = "",
	p_scope: String = "",
	p_extension_script: GDScript = null,
):
	name = p_name
	target_node_class = p_target_node_class
	description = p_description
	category = p_category
	type = p_type
	variant_type = p_variant_type
	display_template = p_display_template
	code_template = p_code_template
	defaults = p_defaults
	signal_name = p_signal_name
	scope = p_scope
	extension_script = p_extension_script


func get_defaults_for_node(parent_node: Node) -> Dictionary:
	if not _extension:
		return defaults

	# Use Dictionary.merge instead of Dictionary.merged for Godot 4.2 compatibility
	var new_defaults := _extension.get_defaults_for_node(parent_node)
	new_defaults.merge(defaults)
	return new_defaults


func _to_string():
	return "%s - %s" % [name, target_node_class]
