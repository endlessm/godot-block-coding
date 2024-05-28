@tool
class_name BlockCanvas
extends MarginContainer

const EXTEND_MARGIN: float = 800

@onready var _window: Control = %Window
@onready var _window_scroll: ScrollContainer = %WindowScroll


func add_block(block: Block) -> void:
	block.position.y += _window_scroll.scroll_vertical
	_window.add_child(block)
	_window.custom_minimum_size.y = max(
		block.position.y + EXTEND_MARGIN, _window.custom_minimum_size.y
	)
