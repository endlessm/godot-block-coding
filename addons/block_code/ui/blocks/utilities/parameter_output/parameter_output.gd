@tool
class_name ParameterOutput
extends MarginContainer

const Types = preload("res://addons/block_code/types/types.gd")

var block: Block
var output_block: Block

@export var block_params: Dictionary

@onready var _snap_point := %SnapPoint


func _ready():
	_snap_point.block_type = Types.BlockType.NONE

	_update_parameter_block.call_deferred()


func _update_parameter_block():
	if _snap_point.has_snapped_block():
		return

	var parameter_block = preload("res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn").instantiate()
	for key in block_params:
		parameter_block[key] = block_params[key]
	parameter_block.spawned_by = self
	_snap_point.add_child.call_deferred(parameter_block)


func _on_parameter_block_drag_started(drag_block: Block):
	block.drag_started.emit(drag_block)


func _on_snap_point_snapped_block_changed(snap_block: Block):
	if snap_block == null:
		return
	# FIXME: The spawned_by property isn't serialized, so we'll set it here to
	#        be sure. In the future, we should try to get rid of this property.
	snap_block.spawned_by = self
	snap_block.drag_started.connect(_on_parameter_block_drag_started)


func _on_snap_point_snapped_block_removed(snap_block: Block):
	snap_block.drag_started.disconnect(_on_parameter_block_drag_started)
	_update_parameter_block.call_deferred()
