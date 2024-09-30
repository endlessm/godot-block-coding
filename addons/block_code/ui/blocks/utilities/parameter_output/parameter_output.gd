@tool
extends MarginContainer

const Types = preload("res://addons/block_code/types/types.gd")
const ParameterBlock = preload("res://addons/block_code/ui/blocks/parameter_block/parameter_block.gd")

var block: Block
var parameter_name: String
var _block_name: String:
	get:
		return block.definition.name if block else ""

@export var block_params: Dictionary

@onready var _context := BlockEditorContext.get_default()

@onready var _snap_point := %SnapPoint


func _ready():
	_update_parameter_block.call_deferred()


func _update_parameter_block():
	if _snap_point == null:
		return

	if _snap_point.has_snapped_block():
		return

	if _context.block_script == null:
		return

	var block_name = &"%s:%s" % [_block_name, parameter_name]
	var parameter_block: ParameterBlock = _context.block_script.instantiate_block_by_name(block_name)

	if parameter_block == null:
		# FIXME: This sometimes occurs when a script is loaded but it is unclear why
		#push_error("Unable to create output block %s." % block_name)
		return

	_snap_point.add_child.call_deferred(parameter_block)


func _on_parameter_block_drag_started(drag_block: Block, offset: Vector2):
	block.drag_started.emit(drag_block, offset)


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
