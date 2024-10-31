extends RefCounted

var name: String
var color: Color
var icon: String
var order: int


func _init(p_name: String = "", p_color: Color = Color.WHITE, p_icon: String = "FileBroken", p_order: int = 0):
	name = p_name
	color = p_color
	icon = p_icon
	order = p_order


## Compare block categories for sorting. Compare by order then name.
static func sort_by_order(a, b) -> bool:
	if a.order != b.order:
		return a.order < b.order
	return a.name.naturalcasecmp_to(b.name) < 0
