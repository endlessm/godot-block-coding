@tool
extends Control

const BlockTreeUtil = preload("res://addons/block_code/ui/block_tree_util.gd")
const Constants = preload("res://addons/block_code/ui/constants.gd")

var outline_color: Color
var parent_block: Block

@export var color: Color:
	set = _set_color

@export var draw_outline: bool = true:
	set = _draw_outline

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

## |0|, \1/, /2/, <3>, >4>, v5v, v6^, \7y, /8y
@export var variant: int = 0:
	set = _variant


func _set_color(new_color):
	color = new_color
	outline_color = color.darkened(0.2)
	queue_redraw()


func _draw_outline(new_outline):
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


func _variant(new_variant):
	variant = clamp(new_variant, 0, 8)
	queue_redraw()


func _ready():
	parent_block = BlockTreeUtil.get_parent_block(self)
	parent_block.focus_entered.connect(queue_redraw)
	parent_block.focus_exited.connect(queue_redraw)


func _draw():
	var fill_polygon: PackedVector2Array
	fill_polygon.append(Vector2(0.0, 0.0))

	if show_top:
		fill_polygon.append(Vector2(Constants.KNOB_X + shift_top, 0.0))
		fill_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z + shift_top, Constants.KNOB_H))
		fill_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z + Constants.KNOB_W + shift_top, Constants.KNOB_H))
		fill_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z * 2 + Constants.KNOB_W + shift_top, 0.0))

	# Right side
	if variant > 0:
		# Top
		if variant == 3 or variant == 4:
			fill_polygon.append(Vector2(size.x - 5.0, 0.0))
		else:
			fill_polygon.append(Vector2(size.x, 0.0))

		# Middle
		if variant == 3 or variant == 4:
			fill_polygon.append(Vector2(size.x, size.y / 2.0))
		elif variant == 5 or variant == 6:
			fill_polygon.append(Vector2(size.x, size.y * 2.0 / 3.0))
		elif variant == 7 or variant == 8:
			fill_polygon.append(Vector2(size.x, size.y / 3.0))

		# Bottom
		fill_polygon.append(Vector2(size.x - 5.0, size.y))
	else:
		fill_polygon.append(Vector2(size.x, 0.0))
		fill_polygon.append(Vector2(size.x, size.y))

	if show_bottom:
		fill_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z * 2 + Constants.KNOB_W + shift_bottom, size.y))
		fill_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z + Constants.KNOB_W + shift_bottom, size.y + Constants.KNOB_H))
		fill_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z + shift_bottom, size.y + Constants.KNOB_H))
		fill_polygon.append(Vector2(Constants.KNOB_X + shift_bottom, size.y))

	# Left side
	if variant > 0:
		# Bottom
		if variant == 2 or variant == 4 or variant == 6 or variant == 8:
			fill_polygon.append(Vector2(0.0, size.y))
		else:
			fill_polygon.append(Vector2(5.0, size.y))

		# Middle
		if variant == 4:
			fill_polygon.append(Vector2(5.0, size.y / 2.0))
		elif variant == 3:
			fill_polygon.append(Vector2(0.0, size.y / 2.0))
		elif variant == 5 or variant == 8:
			fill_polygon.append(Vector2(0.0, size.y * 2 / 3.0))
		elif variant == 6 or variant == 7:
			fill_polygon.append(Vector2(0.0, size.y / 3.0))

		# Top
		if variant == 2 or variant == 3 or variant == 6 or variant == 8:
			fill_polygon.append(Vector2(5.0, 0.0))
		else:
			fill_polygon.append(Vector2(0.0, 0.0))
	else:
		fill_polygon.append(Vector2(0.0, size.y))
		fill_polygon.append(Vector2(0.0, 0.0))

	draw_colored_polygon(fill_polygon, color)

	if draw_outline:
		var stroke_polygon: PackedVector2Array
		var edge_polygon: PackedVector2Array
		var outline_middle = Constants.OUTLINE_WIDTH / 2

		# Top line
		if variant > 0:
			stroke_polygon.append(Vector2(shift_top - (0.0 if not shift_top > 0 else outline_middle) + 5.0, 0.0))
		else:
			stroke_polygon.append(Vector2(shift_top - (0.0 if not shift_top > 0 else outline_middle), 0.0))

		if show_top:
			stroke_polygon.append(Vector2(Constants.KNOB_X + shift_top, 0.0))
			stroke_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z + shift_top, Constants.KNOB_H))
			stroke_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z + Constants.KNOB_W + shift_top, Constants.KNOB_H))
			stroke_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z * 2 + Constants.KNOB_W + shift_top, 0.0))

		# Right line
		if variant > 0:
			# Top
			if variant == 3 or variant == 4:
				stroke_polygon.append(Vector2(size.x - 5.0, 0.0))
			else:
				stroke_polygon.append(Vector2(size.x, 0.0))

			# Middle
			if variant == 3 or variant == 4:
				stroke_polygon.append(Vector2(size.x, size.y / 2.0))
			elif variant == 5 or variant == 6:
				stroke_polygon.append(Vector2(size.x, size.y * 2.0 / 3.0))
			elif variant == 7 or variant == 8:
				stroke_polygon.append(Vector2(size.x, size.y / 3.0))

			# Bottom
			stroke_polygon.append(Vector2(size.x - 5.0, size.y))
		else:
			stroke_polygon.append(Vector2(size.x, 0.0))
			stroke_polygon.append(Vector2(size.x, size.y))

		if show_bottom:
			stroke_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z * 2 + Constants.KNOB_W + shift_bottom, size.y))
			stroke_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z + Constants.KNOB_W + shift_bottom, size.y + Constants.KNOB_H))
			stroke_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z + shift_bottom, size.y + Constants.KNOB_H))
			stroke_polygon.append(Vector2(Constants.KNOB_X + shift_bottom, size.y))

		# Left line
		if variant > 0:
			stroke_polygon.append(Vector2(shift_bottom - (outline_middle if shift_bottom > 0 else 0.0) + 5.0, size.y))
			edge_polygon.append(Vector2(5.0 + outline_middle, 0.0))

			# Top
			if variant == 2 or variant == 3 or variant == 6 or variant == 8:
				edge_polygon.append(Vector2(5.0, 0.0))
			else:
				edge_polygon.append(Vector2(0.0, 0.0))

			# Middle
			if variant == 4:
				edge_polygon.append(Vector2(5.0, size.y / 2.0))
			elif variant == 3:
				edge_polygon.append(Vector2(0.0, size.y / 2.0))
			elif variant == 5 or variant == 8:
				edge_polygon.append(Vector2(0.0, size.y * 2.0 / 3.0))
			elif variant == 6 or variant == 7:
				edge_polygon.append(Vector2(0.0, size.y / 3.0))

			# Bottom
			if variant == 2 or variant == 4 or variant == 6 or variant == 8:
				edge_polygon.append(Vector2(0.0, size.y))
				edge_polygon.append(Vector2(5.0 + outline_middle, size.y))
			else:
				edge_polygon.append(Vector2(5.0, size.y))
				edge_polygon.append(Vector2(5.0 + outline_middle, size.y))
		else:
			stroke_polygon.append(Vector2(shift_bottom - (outline_middle if shift_bottom > 0 else 0.0), size.y))
			edge_polygon.append(Vector2(0.0, 0.0 - (0.0 if shift_top > 0 else outline_middle)))
			edge_polygon.append(Vector2(0.0, size.y + (0.0 if shift_bottom > 0 else outline_middle)))

		draw_polyline(stroke_polygon, Constants.FOCUS_BORDER_COLOR if parent_block.has_focus() else outline_color, Constants.OUTLINE_WIDTH)
		draw_polyline(edge_polygon, Constants.FOCUS_BORDER_COLOR if parent_block.has_focus() else outline_color, Constants.OUTLINE_WIDTH)
