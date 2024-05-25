@tool
class_name MainPanel
extends Control

@onready var _picker: Picker = %Picker
@onready var _block_canvas: BlockCanvas = %BlockCanvas
@onready var _drag_manager: DragManager = %DragManager

var eia: EditorInterfaceAccess

func _ready():
	eia = EditorInterfaceAccess.new()
	
	_picker.block_picked.connect(_drag_manager.copy_picked_block_and_drag)

func block_picked(block: Block) -> void:
	pass


func _on_button_pressed():
	eia.context_switcher_3d_button.visible = false


func _input(event):
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			_drag_manager.drag_ended()
