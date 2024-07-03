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
			return target_snap_point.get_parent_block() if target_snap_point else null

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

	func update_drag_position():
		global_position = get_global_mouse_position()

		for rect in _delete_areas:
			if rect.has_point(get_global_mouse_position()):
				action = DragAction.REMOVE
				target_snap_point = null
				return

		action = DragAction.PLACE

		target_snap_point = _find_closest_snap_point()

	func apply_drag() -> Block:
		update_drag_position()

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

		if _block.block_type != _snap_point.block_type:
			# We only snap to the same block type:
			return false

		if _block.block_type == Types.BlockType.VALUE and not Types.can_cast(_block.variant_type, _snap_point.variant_type):
			# We only snap Value blocks to snaps that can cast to same variant:
			return false

		# Check if any parent node is this node
		if _snap_point.is_ancestor_of(_block):
			return false

		var top_block = _get_top_block_for_node(_snap_point)

		# Check if scope is valid
		if _block_scope != "":
			if top_block is EntryBlock:
				if _block_scope != top_block.get_entry_statement():
					return false
			elif top_block:
				var tree_scope := DragManager.get_tree_scope(top_block)
				if tree_scope != "" and _block_scope != tree_scope:
					return false

		return true

	func _find_closest_snap_point() -> Node:
		var closest_snap_point: SnapPoint = null
		var closest_distance: int
		for snap_point in _snap_points:
			var distance = _get_distance_to_snap_point(snap_point)
			if distance > Constants.MINIMUM_SNAP_DISTANCE:
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
	if drag:
		drag.update_drag_position()


func drag_block(block: Block, copied_from: Block = null):
	var offset: Vector2

	if copied_from and copied_from.is_inside_tree():
		offset = get_global_mouse_position() - copied_from.global_position
	elif block.is_inside_tree():
		offset = get_global_mouse_position() - block.global_position
	else:
		offset = Vector2.ZERO

	var parent = block.get_parent()

	if parent:
		parent.remove_child(block)

	block.disconnect_signals()

	var block_scope := get_tree_scope(block)
	if block_scope != "":
		_block_canvas.set_scope(block_scope)

	drag = Drag.new(block, block_scope, offset, _block_canvas)
	drag.set_snap_points(get_tree().get_nodes_in_group("snap_point"))
	drag.add_delete_area(_picker.get_global_rect())
	if block is ParameterBlock and block.spawned_by:
		drag.add_delete_area(block.spawned_by.get_global_rect())
	add_child(drag)


func copy_block(block: Block) -> Block:
	return block.duplicate(DUPLICATE_USE_INSTANTIATION)  # use instantiation


func copy_picked_block_and_drag(block: Block):
	var new_block: Block = copy_block(block)
	drag_block(new_block, block)


func drag_ended():
	if not drag:
		return

	var block = drag.apply_drag()

	if block:
		connect_block_canvas_signals(block)

	_block_canvas.release_scope()

	drag.queue_free()
	drag = null

	block_dropped.emit()


func connect_block_canvas_signals(block: Block):
	if block.drag_started.get_connections().size() == 0:
		block.drag_started.connect(drag_block)
	if block.modified.get_connections().size() == 0:
		block.modified.connect(func(): block_modified.emit())


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
