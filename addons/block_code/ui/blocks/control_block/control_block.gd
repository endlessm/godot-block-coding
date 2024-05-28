@tool
class_name ControlBlock
extends Block

@export var color: Color = Color(1., 1., 1.):
	set = _set_color

@export var snap_paths: Array[NodePath]

var snaps: Array[SnapPoint]

@onready var _top_bar := %TopBar
@onready var _middle_bar := %MiddleBar
@onready var _bottom_bar := %BottomBar


func _set_color(new_color: Color) -> void:
	color = new_color

	if not is_node_ready():
		return

	_top_bar.color = color
	_middle_bar.color = color.darkened(0.2)
	_bottom_bar.color = color


func _ready():
	super()

	for path in snap_paths:
		snaps.append(get_node(path))

	if Engine.is_editor_hint():
		_set_color(color)


func _on_drag_drop_area_mouse_down():
	_drag_started()


# Override this method to create custom block functionality
func get_instruction_node() -> InstructionTree.TreeNode:
	var main_instruction: String = "for i in range(10):"

	var node: InstructionTree.TreeNode = InstructionTree.TreeNode.new(main_instruction)

	for snap in snaps:
		var snapped_block: Block = snap.get_snapped_block()
		if snapped_block:
			node.add_child(snapped_block.get_instruction_node())

	if bottom_snap:
		var snapped_block: Block = bottom_snap.get_snapped_block()
		if snapped_block:
			node.next = snapped_block.get_instruction_node()

	return node
