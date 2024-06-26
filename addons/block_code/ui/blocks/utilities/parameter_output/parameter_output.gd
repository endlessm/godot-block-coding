@tool
class_name ParameterOutput
extends MarginContainer

var block: Block
var output_block: Block

@export var block_path: NodePath

@export var block_params: Dictionary

@onready var _snap_point := %SnapPoint


func _ready():
	if block == null:
		block = get_node_or_null(block_path)
	_snap_point.block = block
	_snap_point.block_type = Types.BlockType.NONE

	_update_parameter_block()


func _update_parameter_block():
	if _snap_point.has_snapped_block():
		return

	var parameter_block = preload("res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn").instantiate()
	for key in block_params:
		parameter_block[key] = block_params[key]
	_snap_point.add_child.call_deferred(parameter_block)


func _on_parameter_block_drag_started(drag_block: Block):
	block.drag_started.emit(drag_block)


func _on_snap_point_snapped_block_changed(snap_block: Block):
	if snap_block == null:
		return
	snap_block.drag_started.connect(_on_parameter_block_drag_started)


func _on_snap_point_snapped_block_removed(snap_block: Block):
	snap_block.drag_started.disconnect(_on_parameter_block_drag_started)
	_update_parameter_block()
