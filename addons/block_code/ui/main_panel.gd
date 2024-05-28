@tool
class_name MainPanel
extends Control

var eia: EditorInterfaceAccess

@onready var _picker: Picker = %Picker
@onready var _block_canvas: BlockCanvas = %BlockCanvas
@onready var _drag_manager: DragManager = %DragManager


func _ready():
	eia = EditorInterfaceAccess.new()

	_picker.block_picked.connect(_drag_manager.copy_picked_block_and_drag)


func _on_button_pressed():
	eia.context_switcher_3d_button.visible = false


func _input(event):
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			_drag_manager.drag_ended()

	# HACK: play the topmost block
	if event is InputEventKey:
		if event.keycode == KEY_F and event.pressed:
			var topmost: Block = _block_canvas.get_node("WindowScroll/Window").get_child(0)
			var tree: InstructionTree.TreeNode = topmost.get_instruction_node()

			var generator: InstructionTree = InstructionTree.new()
			var script: String = generator.generate_text(tree)
			print(script)
