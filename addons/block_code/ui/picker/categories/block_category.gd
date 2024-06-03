class_name BlockCategory
extends Object

var name: String
var color: Color
var block_list: Array[Block]


func _init(p_name: String = "", p_color: Color = Color.WHITE, p_block_list: Array[Block] = []):
	name = p_name
	color = p_color
	block_list = p_block_list
