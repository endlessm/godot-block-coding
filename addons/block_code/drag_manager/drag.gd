@tool
extends Control

const Background = preload("res://addons/block_code/ui/blocks/utilities/background/background.gd")
const BlockCanvas = preload("res://addons/block_code/ui/block_canvas/block_canvas.gd")
const BlockTreeUtil = preload("res://addons/block_code/ui/block_tree_util.gd")
const Constants = preload("res://addons/block_code/ui/constants.gd")
const Types = preload("res://addons/block_code/types/types.gd")

enum DragAction { NONE, PLACE, REMOVE }

var _block: Block
var _block_scope: String
var _block_canvas: BlockCanvas
var _preview_block: Control
var _snap_points: Array[Node]
var _delete_areas: Array[Rect2]
var action: DragAction:
	get:
		return action
	set(value):
		if action != value:
			action = value
			_update_action_hint()

var target_snap_point: SnapPoint:
	get:
		return target_snap_point
	set(value):
		if target_snap_point != value:
			target_snap_point = value
			_update_preview()

var snap_block: Block:
	get:
		return BlockTreeUtil.get_parent_block(target_snap_point) if target_snap_point else null


func _init(block: Block, block_scope: String, offset: Vector2, block_canvas: BlockCanvas):
	assert(block.get_parent() == null)

	add_child(block)
	block.position = -offset

	_block = block
	_block_scope = block_scope
	_block_canvas = block_canvas


func set_snap_points(snap_points: Array[Node]):
	_snap_points = snap_points.filter(_snaps_to)


func add_delete_area(delete_area: Rect2):
	_delete_areas.append(delete_area)


func update_drag_state():
	global_position = get_global_mouse_position()

	if _block_canvas.is_mouse_over():
		scale = Vector2(_block_canvas.zoom, _block_canvas.zoom)
	else:
		scale = Vector2(1, 1)

	for rect in _delete_areas:
		if rect.has_point(get_global_mouse_position()):
			action = DragAction.REMOVE
			target_snap_point = null
			return

	action = DragAction.PLACE

	target_snap_point = _find_closest_snap_point()


func apply_drag() -> Block:
	update_drag_state()

	if action == DragAction.PLACE:
		_place_block()
		return _block
	elif action == DragAction.REMOVE:
		_remove_block()
		return null
	else:
		return null


func _remove_block():
	target_snap_point = null
	_block.queue_free()


func _place_block():
	var canvas_rect: Rect2 = _block_canvas.get_global_rect()

	var position = _block.global_position - canvas_rect.position

	remove_child(_block)

	if target_snap_point:
		# Snap the block to the point
		var orphaned_block = target_snap_point.insert_snapped_block(_block)
		if orphaned_block:
			# Place the orphan block somewhere outside the snap point
			_block_canvas.arrange_block(orphaned_block, snap_block)
	else:
		# Block goes on screen somewhere
		_block_canvas.add_block(_block, position)

	target_snap_point = null


func _snaps_to(node: Node) -> bool:
	var _snap_point: SnapPoint = node as SnapPoint

	if not _snap_point:
		push_error("Warning: node %s is not of class SnapPoint." % node)
		return false

	if not _block_canvas.is_ancestor_of(_snap_point):
		# We only snap to blocks on the canvas:
		return false

	# We only snap to the same block type: (HACK: Control blocks can snap to statements)
	if not (_block.definition.type == Types.BlockType.CONTROL and _snap_point.block_type == Types.BlockType.STATEMENT):
		if _block.definition.type != _snap_point.block_type:
			return false

	if _block.definition.type == Types.BlockType.VALUE and not Types.can_cast(_block.definition.variant_type, _snap_point.variant_type):
		# We only snap Value blocks to snaps that can cast to same variant:
		return false

	# Check if any parent node is this node
	if _snap_point.is_ancestor_of(_block):
		return false

	var top_block = _get_top_block_for_node(_snap_point)

	# Check if scope is valid
	if _block_scope != "":
		if top_block is EntryBlock:
			if _block_scope != top_block.definition.code_template:
				return false
		elif top_block:
			var tree_scope := BlockTreeUtil.get_tree_scope(top_block)
			if tree_scope != "" and _block_scope != tree_scope:
				return false

	return true


func _find_closest_snap_point() -> Node:
	var closest_snap_point: SnapPoint = null
	var closest_distance: int
	for snap_point in _snap_points:
		var distance = _get_distance_to_snap_point(snap_point)
		if distance > Constants.MINIMUM_SNAP_DISTANCE * _block_canvas.zoom:
			continue
		elif closest_snap_point == null or distance < closest_distance:
			closest_snap_point = snap_point
			closest_distance = distance
	return closest_snap_point


func _get_top_block_for_node(node: Node) -> Block:
	for top_block in _block_canvas.get_blocks():
		if top_block.is_ancestor_of(node):
			return top_block
	return null


func _get_distance_to_snap_point(snap_point: SnapPoint) -> float:
	var from_global: Vector2 = _block.global_position
	return from_global.distance_to(snap_point.global_position)


func _update_action_hint():
	match action:
		DragAction.REMOVE:
			_block.modulate = Color(1.0, 1.0, 1.0, 0.5)
		_:
			_block.modulate = Color.WHITE


func _update_preview():
	if _preview_block:
		_preview_block.queue_free()
		_preview_block = null

	if target_snap_point:
		# Make preview block
		_preview_block = Background.new()

		_preview_block.color = Color(1, 1, 1, 0.5)
		_preview_block.custom_minimum_size = _block.get_global_rect().size
		_preview_block.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		_preview_block.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

		target_snap_point.add_child(_preview_block)
