@tool
extends Control

const BlockTreeUtil = preload("res://addons/block_code/ui/block_tree_util.gd")
const Constants = preload("res://addons/block_code/ui/constants.gd")
const Types = preload("res://addons/block_code/types/types.gd")

enum ControlPart {
	TOP,
	BOTTOM,
}

var outline_color: Color
var parent_block: Block

@export var color: Color:
	set = _set_color

@export var block_type: Types.BlockType = Types.BlockType.STATEMENT:
	set = _set_block_type

## Only relevant if block_type is CONTROL.
@export var control_part: ControlPart = ControlPart.TOP:
	set = _set_control_part

## Only relevant if block_type is VALUE.
@export var is_pointy_value: bool = false:
	set = _set_is_pointy_value


func _set_color(new_color):
	color = new_color
	outline_color = color.darkened(0.2)
	queue_redraw()


func _set_block_type(new_block_type):
	block_type = new_block_type
	queue_redraw()
	notify_property_list_changed()


func _set_control_part(new_control_part):
	control_part = new_control_part
	queue_redraw()


func _set_is_pointy_value(new_is_pointy_value):
	is_pointy_value = new_is_pointy_value
	queue_redraw()


func _validate_property(property: Dictionary):
	if property.name == "control_part" and block_type != Types.BlockType.CONTROL:
		property.usage |= PROPERTY_USAGE_READ_ONLY
	elif property.name == "is_pointy_value" and block_type != Types.BlockType.VALUE:
		property.usage |= PROPERTY_USAGE_READ_ONLY


func _ready():
	parent_block = BlockTreeUtil.get_parent_block(self)
	parent_block.focus_entered.connect(queue_redraw)
	parent_block.focus_exited.connect(queue_redraw)


func _get_border_color() -> Color:
	if parent_block and parent_block.has_focus():
		return Constants.FOCUS_BORDER_COLOR
	return outline_color


func _get_box_shape(box_size: Vector2 = Vector2.ONE) -> PackedVector2Array:
	return PackedVector2Array(
		[
			Vector2(0.0, 0.0),
			Vector2(box_size.x, 0.0),
			Vector2(box_size.x, box_size.y),
			Vector2(0.0, box_size.y),
			Vector2(0.0, 0.0),
		]
	)


func _get_knob_shape(displacement: Vector2 = Vector2.ZERO) -> PackedVector2Array:
	return PackedVector2Array(
		[
			Vector2(displacement.x, displacement.y),
			Vector2(displacement.x + Constants.KNOB_Z, displacement.y + Constants.KNOB_H),
			Vector2(displacement.x + Constants.KNOB_Z + Constants.KNOB_W, displacement.y + Constants.KNOB_H),
			Vector2(displacement.x + Constants.KNOB_Z * 2 + Constants.KNOB_W, displacement.y),
		]
	)


func _get_entry_shape() -> PackedVector2Array:
	var box_shape = _get_box_shape(size)
	var ellipsis = PackedVector2Array(
		[
			Vector2(5, -4.012612),
			Vector2(10, -7.240165),
			Vector2(15, -9.822201),
			Vector2(20, -11.84718),
			Vector2(25, -13.37339),
			Vector2(30, -14.43944),
			Vector2(35, -15.06994),
			Vector2(40, -15.27864),
			Vector2(45, -15.06994),
			Vector2(50, -14.43944),
			Vector2(55, -13.37339),
			Vector2(60, -11.84718),
			Vector2(65, -9.822201),
			Vector2(70, -7.240165),
			Vector2(75, -4.012612),
			Vector2(80, 0),
		]
	)
	var bottom_knob_shape = _get_knob_shape(Vector2(Constants.KNOB_X, size.y))
	bottom_knob_shape.reverse()
	return box_shape.slice(0, 1) + ellipsis + box_shape.slice(1, 3) + bottom_knob_shape + box_shape.slice(3)


func _get_statement_shape() -> PackedVector2Array:
	var box_shape = _get_box_shape(size)
	var top_knob_shape = _get_knob_shape(Vector2(Constants.KNOB_X, 0.0))
	var bottom_knob_shape = _get_knob_shape(Vector2(Constants.KNOB_X, size.y))
	bottom_knob_shape.reverse()
	return box_shape.slice(0, 1) + top_knob_shape + box_shape.slice(1, 3) + bottom_knob_shape + box_shape.slice(3)


# Note: This is a especial case of _get_round_value_shape() with resolution = 2,
# but it's easier this way.
func _get_pointy_value_shape() -> PackedVector2Array:
	var radius_x = min(size.x, size.y) / 2
	var radius_y = max(radius_x, size.y / 2)
	return PackedVector2Array(
		[
			Vector2(radius_x, 0),
			Vector2(size.x - radius_x, 0),
			Vector2(size.x, radius_y),
			Vector2(size.x - radius_x, size.y),
			Vector2(radius_x, size.y),
			Vector2(0, radius_y),
			Vector2(radius_x, 0),
		]
	)


func _get_round_value_shape() -> PackedVector2Array:
	# Normally radius_y will be equal to radius_x. But if the block is more vertical
	# than horizontal, we'll have to deform the arc shapes.
	var radius_x = min(size.x, size.y) / 2
	var radius_y = max(radius_x, size.y / 2)

	var right_arc = []
	for i in range(Constants.ROUND_RESOLUTION):
		var angle = -PI / 2 + PI * i / Constants.ROUND_RESOLUTION
		(
			right_arc
			. append(
				Vector2(
					cos(angle) * radius_x + size.x - radius_x,
					(sin(angle) + 1) * radius_y,
				)
			)
		)
	var left_arc = []
	for i in range(Constants.ROUND_RESOLUTION):
		var angle = PI / 2 + PI * i / Constants.ROUND_RESOLUTION
		(
			left_arc
			. append(
				Vector2(
					(cos(angle) + 1) * radius_x,
					(sin(angle) + 1) * radius_y,
				)
			)
		)
	return PackedVector2Array(
		(
			[
				Vector2(radius_x, 0),
				Vector2(size.x - radius_x, 0),
			]
			+ right_arc
			+ [
				Vector2(size.x - radius_x, size.y),
				Vector2(radius_x, size.y),
			]
			+ left_arc
			+ [
				Vector2(radius_x, 0),
			]
		)
	)


func _get_control_top_fill_shape() -> PackedVector2Array:
	var box_shape = _get_box_shape(size)
	var top_knob_shape = _get_knob_shape(Vector2(Constants.KNOB_X, 0.0))
	var bottom_knob_shape = _get_knob_shape(Vector2(Constants.CONTROL_MARGIN + Constants.KNOB_X, size.y))
	bottom_knob_shape.reverse()
	return box_shape.slice(0, 1) + top_knob_shape + box_shape.slice(1, 3) + bottom_knob_shape + box_shape.slice(3)


func _get_control_top_stroke_shape() -> PackedVector2Array:
	var shape = _get_control_top_fill_shape()
	shape = shape.slice(shape.size() - 2) + shape.slice(0, shape.size() - 2)
	shape.append(Vector2(Constants.CONTROL_MARGIN - Constants.OUTLINE_WIDTH / 2, size.y))
	return shape


func _get_control_bottom_fill_shape() -> PackedVector2Array:
	var box_shape = _get_box_shape(size)
	var top_knob_shape = _get_knob_shape(Vector2(Constants.CONTROL_MARGIN + Constants.KNOB_X, 0.0))
	var bottom_knob_shape = _get_knob_shape(Vector2(Constants.KNOB_X, size.y))
	bottom_knob_shape.reverse()
	return box_shape.slice(0, 1) + top_knob_shape + box_shape.slice(1, 3) + bottom_knob_shape + box_shape.slice(3)


func _get_control_bottom_stroke_shape() -> PackedVector2Array:
	var shape = PackedVector2Array([Vector2(Constants.CONTROL_MARGIN - Constants.OUTLINE_WIDTH / 2, 0.0)])
	return shape + _get_control_bottom_fill_shape().slice(1)


func _draw():
	var fill_polygon: PackedVector2Array
	var stroke_polygon: PackedVector2Array

	match block_type:
		Types.BlockType.ENTRY:
			var shape = _get_entry_shape()
			fill_polygon = shape
			stroke_polygon = shape
		Types.BlockType.STATEMENT:
			var shape = _get_statement_shape()
			fill_polygon = shape
			stroke_polygon = shape
		Types.BlockType.VALUE:
			var shape
			if is_pointy_value:
				shape = _get_pointy_value_shape()
			else:
				shape = _get_round_value_shape()
			fill_polygon = shape
			stroke_polygon = shape
		Types.BlockType.CONTROL:
			if control_part == ControlPart.TOP:
				fill_polygon = _get_control_top_fill_shape()
				stroke_polygon = _get_control_top_stroke_shape()
			else:
				fill_polygon = _get_control_bottom_fill_shape()
				stroke_polygon = _get_control_bottom_stroke_shape()

	draw_colored_polygon(fill_polygon, color)
	draw_polyline(stroke_polygon, _get_border_color(), Constants.OUTLINE_WIDTH)
