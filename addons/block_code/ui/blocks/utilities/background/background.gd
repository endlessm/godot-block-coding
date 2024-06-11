@tool
extends Control

const KNOB_X = 10.0
const KNOB_W = 20.0
const KNOB_H = 5.0
const KNOB_Z = 5.0

@export var color: Color:
	set = _set_color

@export var show_top: bool = true:
	set = _set_show_top

@export var shift_top: float = 0.0:
	set = _set_shift_top

@export var shift_bottom: float = 0.0:
	set = _set_shift_bottom


func _set_color(new_color):
	color = new_color
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
	var polygon = [
		[0.0, 0.0],
		[KNOB_X + shift_top, 0.0],
		[KNOB_X + KNOB_Z + shift_top, KNOB_H],
		[KNOB_X + KNOB_Z + KNOB_W + shift_top, KNOB_H],
		[KNOB_X + KNOB_Z * 2 + KNOB_W + shift_top, 0.0],
		[size.x, 0.0],
		[size.x, size.y],
		[KNOB_X + KNOB_Z * 2 + KNOB_W + shift_bottom, size.y],
		[KNOB_X + KNOB_Z + KNOB_W + shift_bottom, size.y + KNOB_H],
		[KNOB_X + KNOB_Z + shift_bottom, size.y + KNOB_H],
		[KNOB_X + shift_bottom, size.y],
		[0.0, size.y],
		[0.0, 0.0],
	]

	if !show_top:
		for i in 4:
			polygon.remove_at(1)

	var packed_polygon = float_array_to_Vector2Array(polygon)
	draw_colored_polygon(packed_polygon, color)
