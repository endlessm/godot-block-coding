@tool
extends Control

const Constants = preload("res://addons/block_code/ui/constants.gd")

@export var color: Color:
	set = _set_color

@export var outline_color: Color:
	set = _set_outline_color

@export var show_top: bool = true:
	set = _set_show_top

## Horizontally shift the top knob
@export var shift_top: float = 0.0:
	set = _set_shift_top

## Horizontally shift the bottom knob
@export var shift_bottom: float = 0.0:
	set = _set_shift_bottom


func _set_color(new_color):
	color = new_color
	queue_redraw()


func _set_outline_color(new_outline_color):
	outline_color = new_outline_color
	queue_redraw()


func _set_show_top(new_show_top):
	show_top = new_show_top
	queue_redraw()


func _set_shift_top(new_shift_top):
	shift_top = new_shift_top
	queue_redraw()


func _set_shift_bottom(new_shift_bottom):
	shift_bottom = new_shift_bottom
	queue_redraw()


func float_array_to_Vector2Array(coords: Array) -> PackedVector2Array:
	# Convert the array of floats into a PackedVector2Array.
	var array: PackedVector2Array = []
	for coord in coords:
		array.append(Vector2(coord[0], coord[1]))
	return array


func _draw():
	outline_color = color.darkened(0.2)

	var fill_polygon = [[0.0, 0.0]]
	if show_top:
		fill_polygon += [
			[Constants.KNOB_X + shift_top, 0.0],
			[Constants.KNOB_X + Constants.KNOB_Z + shift_top, Constants.KNOB_H],
			[Constants.KNOB_X + Constants.KNOB_Z + Constants.KNOB_W + shift_top, Constants.KNOB_H],
			[Constants.KNOB_X + Constants.KNOB_Z * 2 + Constants.KNOB_W + shift_top, 0.0],
		]
	fill_polygon += [
		[size.x, 0.0],
		[size.x, size.y],
		[Constants.KNOB_X + Constants.KNOB_Z * 2 + Constants.KNOB_W + shift_bottom, size.y],
		[Constants.KNOB_X + Constants.KNOB_Z + Constants.KNOB_W + shift_bottom, size.y + Constants.KNOB_H],
		[Constants.KNOB_X + Constants.KNOB_Z + shift_bottom, size.y + Constants.KNOB_H],
		[Constants.KNOB_X + shift_bottom, size.y],
		[0.0, size.y],
		[0.0, 0.0],
	]

	var stroke_polygon = []
	stroke_polygon += [
		[shift_top, 0.0],
	]
	if show_top:
		stroke_polygon += [
			[Constants.KNOB_X + shift_top, 0.0],
			[Constants.KNOB_X + Constants.KNOB_Z + shift_top, Constants.KNOB_H],
			[Constants.KNOB_X + Constants.KNOB_Z + Constants.KNOB_W + shift_top, Constants.KNOB_H],
			[Constants.KNOB_X + Constants.KNOB_Z * 2 + Constants.KNOB_W + shift_top, 0.0],
		]
	stroke_polygon += [
		[size.x, 0.0],
		[size.x, size.y],
		[Constants.KNOB_X + Constants.KNOB_Z * 2 + Constants.KNOB_W + shift_bottom, size.y],
		[Constants.KNOB_X + Constants.KNOB_Z + Constants.KNOB_W + shift_bottom, size.y + Constants.KNOB_H],
		[Constants.KNOB_X + Constants.KNOB_Z + shift_bottom, size.y + Constants.KNOB_H],
		[Constants.KNOB_X + shift_bottom, size.y],
	]

	stroke_polygon += [
		[shift_bottom, size.y],
	]
	if shift_top + shift_bottom == 0:
		stroke_polygon += [
			[0.0, 0.0],
		]

	var packed_fill_polygon = float_array_to_Vector2Array(fill_polygon)
	var packed_stroke_polygon = float_array_to_Vector2Array(stroke_polygon)
	draw_colored_polygon(packed_fill_polygon, color)
	draw_polyline(packed_stroke_polygon, outline_color, Constants.OUTLINE_WIDTH)
