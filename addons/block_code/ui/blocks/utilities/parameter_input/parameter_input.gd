@tool
class_name ParameterInput
extends MarginContainer

@export var placeholder: String = "Parameter":
	set = _set_placeholder

@export var block_path: NodePath

@export var block_type: Types.BlockType = Types.BlockType.PARAMETER

@onready var _line_edit := %LineEdit
@onready var _snap_point := %SnapPoint


func _set_placeholder(new_placeholder: String) -> void:
	placeholder = new_placeholder

	if not is_node_ready():
		return

	_line_edit.placeholder_text = placeholder


func _ready():
	_set_placeholder(placeholder)

	_snap_point.block = get_node_or_null(block_path)
	_snap_point.block_type = block_type


func get_snapped_block() -> Block:
	return _snap_point.get_snapped_block()


func get_string() -> String:
	var snapped_block: Block = get_snapped_block()
	if snapped_block:
		return snapped_block.get_parameter_string()

	return _line_edit.text
