@tool
extends Control

const BlockTreeUtil = preload("res://addons/block_code/ui/block_tree_util.gd")
const Constants = preload("res://addons/block_code/ui/constants.gd")

var outline_color: Color
var parent_block: Block

@export var color: Color:
	set = _set_color

@export var draw_outline: bool = true:
	set = _set_draw_outline

@export var show_top: bool = true:
	set = _set_show_top

@export var show_bottom: bool = true:
	set = _set_show_bottom

## Horizontally shift the top knob
@export var shift_top: float = 0.0:
	set = _set_shift_top

## Horizontally shift the bottom knob
@export var shift_bottom: float = 0.0:
	set = _set_shift_bottom

enum { BODY, HEADER }

## Style of the top knob
@export var top_variant := BODY:
	set = _set_top_variant

enum { FLAT, POINTED }

## Style of the background |FLAT|, <POINTED>
@export var background_variant := FLAT:
	set = _set_background_variant


func _set_color(new_color):
	color = new_color
	outline_color = color.darkened(0.2)
	queue_redraw()


func _set_draw_outline(new_outline):
	draw_outline = new_outline
	queue_redraw()


func _set_show_top(new_show_top):
	show_top = new_show_top
	queue_redraw()


func _set_show_bottom(new_show_bottom):
	show_bottom = new_show_bottom
	queue_redraw()


func _set_shift_top(new_shift_top):
	shift_top = new_shift_top
	queue_redraw()


func _set_shift_bottom(new_shift_bottom):
	shift_bottom = new_shift_bottom
	queue_redraw()


func _set_top_variant(new_variant):
	top_variant = clamp(new_variant, BODY, HEADER)
	queue_redraw()


func _set_background_variant(new_variant):
	background_variant = clamp(new_variant, FLAT, POINTED)
	queue_redraw()


func _ready():
	# I think the parent block should get the child but this works
	parent_block = BlockTreeUtil.get_parent_block(self)

	if not parent_block == null:
		parent_block.focus_entered.connect(queue_redraw)
		parent_block.focus_exited.connect(queue_redraw)


func _draw():
	var top_left_align := Constants.KNOB_X + shift_top
	var bottom_left_align := Constants.KNOB_X + shift_bottom
	var top_knob: PackedVector2Array
	var fill_polygon: PackedVector2Array
	fill_polygon.append(Vector2(0.0, 0.0))

	if show_top:
		if top_variant == HEADER:
			top_knob.append_array(
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
					Vector2(80, 0)
				]
			)
		else:
			top_knob.append(Vector2(top_left_align, 0.0))
			top_knob.append(Vector2(top_left_align + Constants.KNOB_Z, Constants.KNOB_H))
			top_knob.append(Vector2(top_left_align + Constants.KNOB_Z + Constants.KNOB_W, Constants.KNOB_H))
			top_knob.append(Vector2(top_left_align + Constants.KNOB_Z * 2 + Constants.KNOB_W, 0.0))
		fill_polygon.append_array(top_knob)

	# Right side
	if background_variant == POINTED:
		# Top
		fill_polygon.append(Vector2(size.x - Constants.POINT_WIDTH, 0.0))

		# Middle
		fill_polygon.append(Vector2(size.x, size.y / 2.0))

		# Bottom
		fill_polygon.append(Vector2(size.x - Constants.POINT_WIDTH, size.y))
	else:
		fill_polygon.append(Vector2(size.x, 0.0))
		fill_polygon.append(Vector2(size.x, size.y))

	if show_bottom:
		fill_polygon.append(Vector2(bottom_left_align + Constants.KNOB_Z * 2 + Constants.KNOB_W, size.y))
		fill_polygon.append(Vector2(bottom_left_align + Constants.KNOB_Z + Constants.KNOB_W, size.y + Constants.KNOB_H))
		fill_polygon.append(Vector2(bottom_left_align + Constants.KNOB_Z, size.y + Constants.KNOB_H))
		fill_polygon.append(Vector2(bottom_left_align, size.y))

	# Left side
	if background_variant == POINTED:
		# Bottom
		fill_polygon.append(Vector2(Constants.POINT_WIDTH, size.y))

		# Middle
		fill_polygon.append(Vector2(0.0, size.y / 2.0))

		# Top
		fill_polygon.append(Vector2(Constants.POINT_WIDTH, 0.0))
	else:
		fill_polygon.append(Vector2(0.0, size.y))
		fill_polygon.append(Vector2(0.0, 0.0))

	draw_colored_polygon(fill_polygon, color)

	if draw_outline:
		var stroke_polygon: PackedVector2Array
		var edge_polygon: PackedVector2Array
		var outline_middle := Constants.OUTLINE_WIDTH / 2

		# Top line
		if background_variant == POINTED:
			stroke_polygon.append(Vector2(shift_top - (0.0 if not shift_top > 0 else outline_middle) + Constants.POINT_WIDTH, 0.0))
		else:
			stroke_polygon.append(Vector2(shift_top - (0.0 if not shift_top > 0 else outline_middle), 0.0))

		if show_top:
			stroke_polygon.append_array(top_knob)

		# Right line
		if background_variant == POINTED:
			# Top
			stroke_polygon.append(Vector2(size.x - Constants.POINT_WIDTH, 0.0))

			# Middle
			stroke_polygon.append(Vector2(size.x, size.y / 2.0))

			# Bottom
			stroke_polygon.append(Vector2(size.x - Constants.POINT_WIDTH, size.y))
		else:
			stroke_polygon.append(Vector2(size.x, 0.0))
			stroke_polygon.append(Vector2(size.x, size.y))

		if show_bottom:
			stroke_polygon.append(Vector2(bottom_left_align + Constants.KNOB_Z * 2 + Constants.KNOB_W, size.y))
			stroke_polygon.append(Vector2(bottom_left_align + Constants.KNOB_Z + Constants.KNOB_W, size.y + Constants.KNOB_H))
			stroke_polygon.append(Vector2(bottom_left_align + Constants.KNOB_Z, size.y + Constants.KNOB_H))
			stroke_polygon.append(Vector2(bottom_left_align, size.y))

		# Left line
		if background_variant == POINTED:
			stroke_polygon.append(Vector2(shift_bottom - (outline_middle if shift_bottom > 0 else 0.0) + Constants.POINT_WIDTH, size.y))
			edge_polygon.append(Vector2(Constants.POINT_WIDTH + outline_middle, 0.0))

			# Top
			edge_polygon.append(Vector2(Constants.POINT_WIDTH, 0.0))

			# Middle
			edge_polygon.append(Vector2(0.0, size.y / 2.0))

			# Bottom
			edge_polygon.append(Vector2(Constants.POINT_WIDTH, size.y))
			edge_polygon.append(Vector2(Constants.POINT_WIDTH + outline_middle, size.y))
		else:
			stroke_polygon.append(Vector2(shift_bottom - (outline_middle if shift_bottom > 0 else 0.0), size.y))
			edge_polygon.append(Vector2(0.0, 0.0 - (0.0 if shift_top > 0 else outline_middle)))
			edge_polygon.append(Vector2(0.0, size.y + (0.0 if shift_bottom > 0 else outline_middle)))

		if parent_block == null:
			draw_polyline(stroke_polygon, outline_color, Constants.OUTLINE_WIDTH)
			draw_polyline(edge_polygon, outline_color, Constants.OUTLINE_WIDTH)
		else:
			draw_polyline(stroke_polygon, Constants.FOCUS_BORDER_COLOR if parent_block.has_focus() else outline_color, Constants.OUTLINE_WIDTH)
			draw_polyline(edge_polygon, Constants.FOCUS_BORDER_COLOR if parent_block.has_focus() else outline_color, Constants.OUTLINE_WIDTH)
