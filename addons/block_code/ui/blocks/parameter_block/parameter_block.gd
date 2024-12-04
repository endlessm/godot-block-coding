@tool
class_name ParameterBlock
extends Block

const Constants = preload("res://addons/block_code/ui/constants.gd")
const Util = preload("res://addons/block_code/ui/util.gd")
const ParameterOutput = preload("res://addons/block_code/ui/blocks/utilities/parameter_output/parameter_output.gd")

@onready var _background := %Background

var args_to_add_after_format: Dictionary  # Only used when loading
var spawned_by: ParameterOutput


func _ready():
	super()
	_background.color = color
	_update_block_shape()


func _on_definition_changed():
	super()
	_update_block_shape()


func _update_block_shape():
	if not definition:
		return
	await ready
	_background.is_pointy_value = definition.variant_type == TYPE_BOOL


func _on_drag_drop_area_drag_started(offset: Vector2) -> void:
	_drag_started(offset)


static func get_block_class():
	return "ParameterBlock"


static func get_scene_path():
	return "res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn"
