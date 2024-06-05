class_name BlockCategory
extends Object

var name: String
var block_list: Array[Block]
var color: Color


func _init(p_name: String = "", p_block_list: Array[Block] = [], p_color: Color = Color.WHITE):
	name = p_name
	block_list = p_block_list
	color = p_color
