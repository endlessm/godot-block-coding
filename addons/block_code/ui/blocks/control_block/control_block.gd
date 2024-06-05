@tool
class_name ControlBlock
extends Block

@export var snap_paths: Array[NodePath]

var snaps: Array[SnapPoint]

@onready var _top_bar := %TopBar
@onready var _middle_bar := %MiddleBar
@onready var _bottom_bar := %BottomBar
@onready var _label := %Label


func _ready():
	super()

	for path in snap_paths:
		snaps.append(get_node(path))

	_top_bar.color = color
	_middle_bar.color = color.darkened(0.2)
	_bottom_bar.color = color

	_label.text = label


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


func get_scene_path():
	return "res://addons/block_code/ui/blocks/control_block/control_block.tscn"
