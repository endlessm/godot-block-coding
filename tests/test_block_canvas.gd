extends GutTest
## Tests for BlockCanvas

const BlockCanvas = preload("res://addons/block_code/ui/block_canvas/block_canvas.gd")


func test_get_classname_for_property():
	assert_eq(BlockCanvas._get_classname_for_property(&"Sprite2D", &"flip_h"), &"Sprite2D")
	assert_eq(BlockCanvas._get_classname_for_property(&"Sprite2D", &"position"), &"Node2D")
	assert_eq(BlockCanvas._get_classname_for_property(&"Sprite2D", &"visible"), &"CanvasItem")
