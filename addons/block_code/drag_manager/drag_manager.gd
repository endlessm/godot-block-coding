@tool
class_name DragManager
extends Control

signal block_dropped
signal block_modified

@export var picker_path: NodePath
@export var block_canvas_path: NodePath

const Constants = preload("res://addons/block_code/ui/constants.gd")

var drag_offset: Vector2
var dragging: Block = null

var previewing_snap_point: SnapPoint = null
var preview_block: Control = null
var preview_owner: Block = null

var _picker: Picker
var _block_canvas: BlockCanvas


func _ready():
	_picker = get_node(picker_path)
	_block_canvas = get_node(block_canvas_path)


func _process(_delta):
	var mouse_pos: Vector2 = get_local_mouse_position()
	if dragging:
		dragging.position = mouse_pos - drag_offset

		var dragging_global_pos: Vector2 = dragging.get_global_rect().position

		# TODO: check if dropped snap point is occupied
		# if so, replace with this node and attach the previous one
		# to this node's bottom snap

		# Find closest snap point not child of current node
		var closest_snap_point: SnapPoint = null
		var closest_dist: float = INF
		var snap_points: Array[Node] = get_tree().get_nodes_in_group("snap_point")
		for snap_point in snap_points:
			if not snap_point is SnapPoint:
				push_error('Warning: a node in group "snap_point"snap is not of class SnapPoint.')
				continue
			if snap_point.block == null:
				push_error("Warning: a snap point does not reference it's parent block.")
				continue
			if not snap_point.block.on_canvas:
				# We only snap to blocks on the canvas:
				continue
			if dragging.block_type != snap_point.block_type:
				# We only snap to the same block type:
				continue
			if dragging.block_type == Types.BlockType.VALUE and not Types.can_cast(dragging.variant_type, snap_point.variant_type):
				# We only snap Value blocks to snaps that can cast to same variant:
				continue
			var snap_global_pos: Vector2 = snap_point.get_global_rect().position
			var temp_dist: float = dragging_global_pos.distance_to(snap_global_pos)
			if temp_dist <= Constants.MINIMUM_SNAP_DISTANCE and temp_dist < closest_dist:
				# Check if any parent node is this node
				var is_child: bool = false
				var parent = snap_point
				while parent is SnapPoint:
					if parent.block == dragging:
						is_child = true

					parent = parent.block.get_parent()

				if not is_child:
					closest_dist = temp_dist
					closest_snap_point = snap_point

		if closest_snap_point != previewing_snap_point:
			_update_preview(closest_snap_point)


func _update_preview(snap_point: SnapPoint):
	previewing_snap_point = snap_point

	if preview_block:
		preview_block.free()
		preview_block = null

	if previewing_snap_point:
		# Make preview block
		preview_block = Control.new()
		preview_block.set_script(preload("res://addons/block_code/ui/blocks/utilities/background/background.gd"))

		preview_block.color = Color(1, 1, 1, 0.5)
		preview_block.custom_minimum_size = dragging.get_global_rect().size
		preview_block.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

		previewing_snap_point.add_child(preview_block)


func drag_block(block: Block, copied_from: Block = null):
	var new_pos: Vector2 = -get_global_rect().position

	if copied_from:
		new_pos += copied_from.get_global_rect().position
	else:
		new_pos += block.get_global_rect().position

	var parent = block.get_parent()
	if parent:
		parent.remove_child(block)

	block.position = new_pos
	block.on_canvas = false
	add_child(block)

	drag_offset = get_local_mouse_position() - block.position
	dragging = block


func copy_block(block: Block) -> Block:
	return block.duplicate(DUPLICATE_USE_INSTANTIATION)  # use instantiation


func copy_picked_block_and_drag(block: Block):
	var new_block: Block = copy_block(block)

	drag_block(new_block, block)


func drag_ended():
	if dragging:
		var block_rect: Rect2 = dragging.get_global_rect()

		# Check if in BlockCanvas
		var block_canvas_rect: Rect2 = _block_canvas.get_global_rect()
		if block_canvas_rect.encloses(block_rect):
			dragging.disconnect_signals()  # disconnect previous on canvas signal connections
			connect_block_canvas_signals(dragging)
			remove_child(dragging)
			dragging.on_canvas = true

			if preview_block:
				# Can snap block
				preview_block.free()
				preview_block = null
				previewing_snap_point.add_child(dragging)
			else:
				# Block goes on screen somewhere
				dragging.position = (get_global_mouse_position() - block_canvas_rect.position - drag_offset)
				_block_canvas.add_block(dragging)
		else:
			dragging.queue_free()

		dragging = null
		block_dropped.emit()


func connect_block_canvas_signals(block: Block):
	block.drag_started.connect(drag_block)
	block.modified.connect(func(): block_modified.emit())

	# HACK: for statement blocks connect copy_blocks to necessary signal
	if block is StatementBlock:
		var statement_block := block as StatementBlock
		for pair in statement_block.param_name_input_pairs:
			var param_input: ParameterInput = pair[1]
			var b := param_input.get_snapped_block()
			if b:
				if b.drag_started.get_connections().size() == 0:
					b.drag_started.connect(copy_picked_block_and_drag)
