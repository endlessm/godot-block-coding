@tool
extends Control

const Constants = preload("res://addons/block_code/ui/constants.gd")

var outline_color: Color

@export var color: Color:
	set = _set_color


func _set_color(new_color):
	color = new_color
	outline_color = color.darkened(0.2)
	queue_redraw()


func _draw():
	var fill_polygon: PackedVector2Array
	fill_polygon.append(Vector2(0.0, 0.0))
	fill_polygon.append(Vector2(size.x, 0.0))
	fill_polygon.append(Vector2(size.x, size.y))
	fill_polygon.append(Vector2(0.0, size.y))
	fill_polygon.append(Vector2(0.0, 0.0))

	var left_polygon: PackedVector2Array
	var right_polygon: PackedVector2Array

	left_polygon.append(Vector2(0.0, 0.0))
	left_polygon.append(Vector2(0.0, size.y))

	right_polygon.append(Vector2(size.x, 0.0))
	right_polygon.append(Vector2(size.x, size.y))

	draw_colored_polygon(fill_polygon, color)
	draw_polyline(left_polygon, outline_color, Constants.OUTLINE_WIDTH)
	draw_polyline(right_polygon, outline_color, Constants.OUTLINE_WIDTH)
