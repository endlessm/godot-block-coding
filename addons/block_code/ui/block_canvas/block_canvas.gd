@tool
class_name BlockCanvas
extends MarginContainer

const EXTEND_MARGIN: float = 800

@onready var _window: Control = %Window
@onready var _window_scroll: ScrollContainer = %WindowScroll


func add_block(block: Block) -> void:
	block.position.y += _window_scroll.scroll_vertical
	_window.add_child(block)
	block.owner = _window  # Important for save window
	_window.custom_minimum_size.y = max(block.position.y + EXTEND_MARGIN, _window.custom_minimum_size.y)


func clear_canvas():
	for child in _window.get_children():
		child.queue_free()


func load_canvas():
	var scene: PackedScene = ResourceLoader.load("user://test_canvas.tscn")
	var new_window := scene.instantiate()
	_window.queue_free()
	_window = new_window
	_window_scroll.add_child(_window)


func save_canvas():
	var scene := PackedScene.new()

	var pack_error := scene.pack(_window)

	if pack_error != OK:
		push_error("An error occurred while saving the canvas to disk.")
		return

	var save_error := ResourceSaver.save(scene, "user://test_canvas.tscn")

	if save_error != OK:
		push_error("An error occurred while saving the scene to disk.")
