@tool
class_name ControlBlock
extends Block

const Background = preload("res://addons/block_code/ui/blocks/utilities/background/background.gd")
const Constants = preload("res://addons/block_code/ui/constants.gd")
const DragDropArea = preload("res://addons/block_code/ui/blocks/utilities/drag_drop_area/drag_drop_area.gd")
const Gutter = preload("res://addons/block_code/ui/blocks/utilities/background/gutter.gd")

@export var block_formats: Array = []
@export var statements: Array = []
@export var defaults: Dictionary = {}

var snaps: Array
var param_name_input_pairs_array: Array
var param_input_strings_array: Array  # Only loaded from serialized


func _ready():
	super()

	format()

	if param_input_strings_array:
		for i in param_name_input_pairs_array.size():
			for pair in param_name_input_pairs_array[i]:
				pair[1].set_raw_input(param_input_strings_array[i][pair[0]])


func _on_drag_drop_area_mouse_down():
	_drag_started()


# Override this method to create custom block functionality
func get_instruction_node() -> InstructionTree.TreeNode:
	var root: InstructionTree.TreeNode = InstructionTree.TreeNode.new("")
	var node: InstructionTree.TreeNode

	for i in snaps.size():
		var snap: SnapPoint = snaps[i]
		var formatted_statement: String = statements[i]

		for pair in param_name_input_pairs_array[i]:
			formatted_statement = formatted_statement.replace("{%s}" % pair[0], pair[1].get_string())

		formatted_statement = InstructionTree.IDHandler.make_unique(formatted_statement)

		var new_node := InstructionTree.TreeNode.new(formatted_statement)
		if i == 0:
			node = new_node
			root = node
		else:
			node.next = new_node
			node = node.next

		var snapped_block: Block = snap.get_snapped_block()
		if snapped_block:
			node.add_child(snapped_block.get_instruction_node())
		else:
			node.add_child(InstructionTree.TreeNode.new("pass"))
#
	if bottom_snap:
		var snapped_block: Block = bottom_snap.get_snapped_block()
		if snapped_block:
			node.next = snapped_block.get_instruction_node()

	return root


func get_serialized_props() -> Array:
	var props := super()
	if not BlocksCatalog.has_block(block_name):
		props.append_array(serialize_props(["block_formats", "statements", "defaults"]))

	var _param_input_strings_array = []
	for param_name_input_pairs in param_name_input_pairs_array:
		var _param_input_strings: Dictionary = {}

		for pair in param_name_input_pairs:
			_param_input_strings[pair[0]] = pair[1].get_raw_input()

		_param_input_strings_array.append(_param_input_strings)

	props.append(["param_input_strings_array", _param_input_strings_array])
	return props


static func get_block_class():
	return "ControlBlock"


static func get_scene_path():
	return "res://addons/block_code/ui/blocks/control_block/control_block.tscn"


func format():
	snaps = []
	param_name_input_pairs_array = []

	if block_formats.size() == 0:
		return

	for i in block_formats.size():
		var row := MarginContainer.new()
		row.name = "Row%d" % i
		row.custom_minimum_size.x = 80
		row.custom_minimum_size.y = 30
		row.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

		var bg := Background.new()
		bg.name = "Background"
		bg.color = color
		if i != 0:
			bg.shift_top = Constants.CONTROL_MARGIN
		bg.shift_bottom = Constants.CONTROL_MARGIN
		row.add_child(bg)

		if i == 0:
			var drag_drop: DragDropArea = preload("res://addons/block_code/ui/blocks/utilities/drag_drop_area/drag_drop_area.tscn").instantiate()
			row.add_child(drag_drop)
			drag_drop.mouse_down.connect(_drag_started)

		var row_hbox_container := MarginContainer.new()
		row_hbox_container.name = "RowHBoxContainer"
		row_hbox_container.add_theme_constant_override("margin_left", 10)
		row_hbox_container.add_theme_constant_override("margin_right", 6)
		row_hbox_container.add_theme_constant_override("margin_top", 12)
		row_hbox_container.add_theme_constant_override("margin_bottom", 6)
		row_hbox_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(row_hbox_container)

		var row_hbox := HBoxContainer.new()
		row_hbox.name = "RowHBox"
		row_hbox.add_theme_constant_override("separation", 0)
		row_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row_hbox_container.add_child(row_hbox)

		param_name_input_pairs_array.append(StatementBlock.format_string(self, row_hbox, block_formats[i], defaults))

		%Rows.add_child(row)

		var snap_container := MarginContainer.new()
		snap_container.name = "SnapContainer%d" % i
		snap_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		snap_container.custom_minimum_size.x = 30
		snap_container.custom_minimum_size.y = 30
		snap_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

		var snap_gutter := Gutter.new()
		snap_gutter.name = "Background"
		snap_gutter.custom_minimum_size.x = Constants.CONTROL_MARGIN
		snap_gutter.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		snap_gutter.size_flags_vertical = Control.SIZE_EXPAND_FILL
		snap_gutter.color = color
		snap_container.add_child(snap_gutter)

		var snap_point: SnapPoint = preload("res://addons/block_code/ui/blocks/utilities/snap_point/snap_point.tscn").instantiate()
		snap_point.add_theme_constant_override("margin_left", Constants.CONTROL_MARGIN)
		snap_container.add_child(snap_point)

		snaps.append(snap_point)

		%Rows.add_child(snap_container)

	var bg := Background.new()
	bg.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	bg.custom_minimum_size.x = 100
	bg.custom_minimum_size.y = 30
	bg.color = color
	bg.shift_top = Constants.CONTROL_MARGIN
	%Rows.add_child(bg)
