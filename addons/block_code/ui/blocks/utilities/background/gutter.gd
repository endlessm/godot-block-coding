@tool
extends Control

const BlockTreeUtil = preload("res://addons/block_code/ui/block_tree_util.gd")
const Constants = preload("res://addons/block_code/ui/constants.gd")

var outline_color: Color
var parent_block: Block

@export var color: Color:
	set = _set_color


func _set_color(new_color):
	color = new_color
	outline_color = color.darkened(0.2)
	queue_redraw()


func _ready():
	parent_block = BlockTreeUtil.get_parent_block(self)
	parent_block.focus_entered.connect(queue_redraw)
	parent_block.focus_exited.connect(queue_redraw)


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
	draw_polyline(left_polygon, Constants.FOCUS_BORDER_COLOR if parent_block.has_focus() else outline_color, Constants.OUTLINE_WIDTH)
	draw_polyline(right_polygon, Constants.FOCUS_BORDER_COLOR if parent_block.has_focus() else outline_color, Constants.OUTLINE_WIDTH)
