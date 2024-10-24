@tool
## Drag drop area.
##
## A Control which watches for click and drag gestures beginning from itself.
## It propagates events up to its parent, so it is possible to place this
## control inside a control which processes input events such as [LineEdit].
## If a drag occurs, it emits [signal drag_started].
extends Control

const Constants = preload("res://addons/block_code/ui/constants.gd")
const BlockTreeUtil = preload("res://addons/block_code/ui/block_tree_util.gd")

signal drag_started(offset: Vector2)

## True to require that the mouse move outside of the component before
## [signal drag_started] is emitted.
@export var drag_outside: bool = false

var _drag_start_position: Vector2 = Vector2.INF
var parent_block: Block


func _gui_input(event: InputEvent) -> void:
	# Watch for mouse clicks using _gui_input, so events are filtered based on
	# rules of the GUI system.

	if not event is InputEventMouseButton:
		return

	var button_event: InputEventMouseButton = event as InputEventMouseButton

	if button_event.button_index != MOUSE_BUTTON_LEFT and button_event.button_index != MOUSE_BUTTON_RIGHT:
		return

	if button_event.double_click:
		# Double click event (with the mouse released) has both pressed=true
		# and double_click=true, so ignore it as a special case.
		pass
	elif button_event.pressed:
		# Keep track of where the mouse click originated, but allow this
		# event to propagate to other nodes.
		if button_event.button_index == MOUSE_BUTTON_LEFT:
			_drag_start_position = event.global_position
		else:
			if not parent_block:
				parent_block = BlockTreeUtil.get_parent_block(self)

			if parent_block and parent_block.can_delete:
				# Accepts to avoid menu conflicts
				accept_event()

				# A new right-click menu with items
				var _context_menu := PopupMenu.new()
				_context_menu.add_icon_item(EditorInterface.get_editor_theme().get_icon("Duplicate", "EditorIcons"), "Duplicate")
				_context_menu.add_icon_item(EditorInterface.get_editor_theme().get_icon("Remove", "EditorIcons"), "Delete")
				_context_menu.popup_hide.connect(_cleanup)
				_context_menu.id_pressed.connect(_menu_pressed.bind(_context_menu))

				_context_menu.position = DisplayServer.mouse_get_position()
				add_child(_context_menu)

				_context_menu.show()
	else:
		_drag_start_position = Vector2.INF


func _input(event: InputEvent) -> void:
	# Watch for mouse movements using _input. This way, we receive mouse
	# motion events that occur outside of the component before the GUI system
	# does.

	if not event is InputEventMouseMotion:
		return

	if _drag_start_position == Vector2.INF:
		return

	var motion_event: InputEventMouseMotion = event as InputEventMouseMotion

	if drag_outside and get_global_rect().has_point(motion_event.global_position):
		return

	if _drag_start_position.distance_to(motion_event.global_position) < Constants.MINIMUM_DRAG_THRESHOLD:
		return

	get_viewport().set_input_as_handled()
	drag_started.emit(_drag_start_position - motion_event.global_position)
	_drag_start_position = Vector2.INF


func _menu_pressed(_index: int, _context_menu: PopupMenu):
	# Getting which item was pressed and the corresponding function
	var _pressed_label: String = _context_menu.get_item_text(_index)

	if _pressed_label == "Duplicate":
		parent_block.confirm_duplicate()
	elif _pressed_label == "Delete":
		parent_block.confirm_delete()


func _cleanup():
	for child in get_children():
		remove_child(child)
		child.queue_free()
