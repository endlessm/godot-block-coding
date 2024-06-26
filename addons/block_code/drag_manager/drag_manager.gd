@tool
class_name DragManager
extends Control

signal block_dropped
signal block_modified

@export var picker_path: NodePath
@export var block_canvas_path: NodePath

const Constants = preload("res://addons/block_code/ui/constants.gd")

enum DragAction { NONE, PLACE, REMOVE }


class Drag:
	extends Control
	var _block: Block
	var _block_scope: String
	var _block_canvas: BlockCanvas
	var _preview_block: Control
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
			return target_snap_point.block if target_snap_point else null

	func _init(block: Block, block_scope: String, offset: Vector2, block_canvas: BlockCanvas):
		assert(block.get_parent() == null)

		add_child(block)
		block.position = -offset

		_block = block
		_block_scope = block_scope
		_block_canvas = block_canvas

	func apply_drag() -> Block:
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
			var orphaned_block = target_snap_point.set_snapped_block(_block)
			if orphaned_block:
				# Place the orphan block somewhere outside the snap point
				_block_canvas.arrange_block(orphaned_block, snap_block)
		else:
			# Block goes on screen somewhere
			_block_canvas.add_block(_block, position)

		target_snap_point = null

	func snaps_to(node: Node) -> bool:
		var _snap_point: SnapPoint = node as SnapPoint

		if not _snap_point:
			push_error("Warning: node %s is not of class SnapPoint." % node)
			return false

		if _snap_point.block == null:
			push_error("Warning: snap point %s does not reference its parent block." % _snap_point)
			return false

		if not _block_canvas.is_ancestor_of(_snap_point):
			# We only snap to blocks on the canvas:
			return false

		if _block.block_type != _snap_point.block_type:
			# We only snap to the same block type:
			return false

		if _block.block_type == Types.BlockType.VALUE and not Types.can_cast(_block.variant_type, _snap_point.variant_type):
			# We only snap Value blocks to snaps that can cast to same variant:
			return false

		if _get_distance_to_snap_point(_snap_point) > Constants.MINIMUM_SNAP_DISTANCE:
			return false

		# Check if any parent node is this node
		var parent = _snap_point
		var top_block
		while parent is SnapPoint:
			if parent.block == _block:
				return false

			top_block = parent.block
			parent = parent.block.get_parent()

		# Check if scope is valid
		if _block_scope != "":
			if top_block is EntryBlock:
				if _block_scope != top_block.get_entry_statement():
					return false
			else:
				var tree_scope := DragManager.get_tree_scope(top_block)
				if tree_scope != "" and _block_scope != tree_scope:
					return false

		return true

	func sort_snap_points_by_distance(a: SnapPoint, b: SnapPoint):
		return _get_distance_to_snap_point(a) < _get_distance_to_snap_point(b)

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
			_preview_block = Control.new()
			_preview_block.set_script(preload("res://addons/block_code/ui/blocks/utilities/background/background.gd"))

			_preview_block.color = Color(1, 1, 1, 0.5)
			_preview_block.custom_minimum_size = _block.get_global_rect().size
			_preview_block.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			_preview_block.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

			target_snap_point.add_child(_preview_block)


var _picker: Picker
var _block_canvas: BlockCanvas

var drag: Drag = null


func _ready():
	_picker = get_node(picker_path)
	_block_canvas = get_node(block_canvas_path)


func _process(_delta):
	_update_drag_position()


func _update_drag_position():
	if not drag:
		return

	drag.position = get_local_mouse_position()

	if _picker.get_global_rect().has_point(get_global_mouse_position()):
		drag.action = DragAction.REMOVE
	else:
		drag.action = DragAction.PLACE

	# Find closest snap point not child of current node
	var snap_points: Array[Node] = get_tree().get_nodes_in_group("snap_point").filter(drag.snaps_to)
	snap_points.sort_custom(drag.sort_snap_points_by_distance)

	drag.target_snap_point = snap_points[0] if snap_points.size() > 0 else null


func drag_block(block: Block, copied_from: Block = null):
	var offset: Vector2

	if copied_from:
		offset = get_global_mouse_position() - copied_from.global_position
	else:
		offset = get_global_mouse_position() - block.global_position

	var parent = block.get_parent()

	if parent is SnapPoint:
		parent.remove_snapped_block(block)
	elif parent:
		parent.remove_child(block)

	block.disconnect_signals()

	var block_scope := get_tree_scope(block)
	if block_scope != "":
		_block_canvas.set_scope(block_scope)

	drag = Drag.new(block, block_scope, offset, _block_canvas)
	add_child(drag)


func copy_block(block: Block) -> Block:
	return block.duplicate(DUPLICATE_USE_INSTANTIATION)  # use instantiation


func copy_picked_block_and_drag(block: Block):
	var new_block: Block = copy_block(block)
	drag_block(new_block, block)


func drag_ended():
	if not drag:
		return

	_update_drag_position()

	var block = drag.apply_drag()

	if block:
		connect_block_canvas_signals(block)

	_block_canvas.release_scope()

	drag.queue_free()
	drag = null

	block_dropped.emit()


func connect_block_canvas_signals(block: Block):
	block.drag_started.connect(drag_block)
	block.modified.connect(func(): block_modified.emit())

	# HACK: for statement blocks connect copy_blocks to necessary signal
	if block is StatementBlock:
		var statement_block := block as StatementBlock
		for pair in statement_block.param_name_input_pairs:
			var param_input: ParameterInput = pair[1]
			var copy_block := param_input.get_snapped_block()
			if copy_block == null:
				continue
			if copy_block.drag_started.get_connections().size() == 0:
				copy_block.drag_started.connect(func(b: Block): drag_copy_parameter(b, block))


func drag_copy_parameter(block: Block, parent: Block):
	if parent is EntryBlock:
		block.scope = parent.get_entry_statement()
	copy_picked_block_and_drag(block)


## Returns the scope of the first non-empty scope child block
static func get_tree_scope(node: Node) -> String:
	if node is Block:
		if node.scope != "":
			return node.scope

	for c in node.get_children():
		var scope := get_tree_scope(c)
		if scope != "":
			return scope
	return ""
