@tool
class_name StatementBlock
extends Block

@export var block_format: String = ""
@export var statement: String = ""

@onready var _top_bar := %TopBar
@onready var _hbox := %HBoxContainer

var param_name_input_pairs: Array
var param_input_strings: Dictionary  # Only loaded from serialized


func _ready():
	super()

	_top_bar.color = color

	format()

	if param_input_strings:
		for pair in param_name_input_pairs:
			pair[1].set_plain_text(param_input_strings[pair[0]])


func _on_drag_drop_area_mouse_down():
	_drag_started()


func get_serialized_props() -> Array:
	var props := super()
	props.append_array(serialize_props(["block_format", "statement"]))

	var _param_input_strings: Dictionary = {}
	for pair in param_name_input_pairs:
		_param_input_strings[pair[0]] = pair[1].get_plain_text()

	props.append(["param_input_strings", _param_input_strings])
	return props


func get_scene_path():
	return "res://addons/block_code/ui/blocks/statement_block/statement_block.tscn"


# Override this method to create custom block functionality
func get_instruction_node() -> InstructionTree.TreeNode:
	var formatted_statement := statement

	for pair in param_name_input_pairs:
		formatted_statement = formatted_statement.replace("{%s}" % pair[0], pair[1].get_string())

	var statement_lines := formatted_statement.split("\n")

	var root: InstructionTree.TreeNode = InstructionTree.TreeNode.new(statement_lines[0])
	var node := root

	for i in range(1, statement_lines.size()):
		node.next = InstructionTree.TreeNode.new(statement_lines[i])
		node = node.next

	if bottom_snap:
		var snapped_block: Block = bottom_snap.get_snapped_block()
		if snapped_block:
			node.next = snapped_block.get_instruction_node()

	return root


func format():
	param_name_input_pairs = format_string(self, %HBoxContainer, block_format)


static func format_string(parent_block: Block, attach_to: Node, string: String) -> Array:
	var _param_name_input_pairs = []
	var regex = RegEx.new()
	regex.compile("\\{([^}]+)\\}")  # Capture things of format {test: INT}
	var results := regex.search_all(string)

	var start: int = 0
	for result in results:
		var label_text := string.substr(start, result.get_start() - start)
		if label_text != "":
			var label = Label.new()
			label.add_theme_color_override("font_color", Color.WHITE)
			label.text = label_text
			attach_to.add_child(label)

		var param := result.get_string()
		param = param.substr(1, param.length() - 2)
		var split := param.split(": ")
		var param_name := split[0]
		var param_type_str := split[1]
		var param_type := Types.BlockType.get(param_type_str)

		var param_input: ParameterInput = preload("res://addons/block_code/ui/blocks/utilities/parameter_input/parameter_input.tscn").instantiate()
		param_input.name = "ParameterInput%d" % start  # Unique path
		param_input.placeholder = param_name
		param_input.block_type = param_type
		param_input.block = parent_block
		param_input.text_modified.connect(func(): parent_block.modified.emit())
		attach_to.add_child(param_input)  # Can't use onready var
		_param_name_input_pairs.append([param_name, param_input])

		start = result.get_end()

	var label_text := string.substr(start)
	if label_text != "":
		var label = Label.new()
		label.add_theme_color_override("font_color", Color.WHITE)
		label.text = label_text
		attach_to.add_child(label)

	return _param_name_input_pairs
