@tool
class_name ParameterInput
extends MarginContainer

signal modified

@export var placeholder: String = "Parameter":
	set = _set_placeholder

@export var block_path: NodePath

@export var variant_type: Variant.Type = TYPE_STRING
@export var block_type: Types.BlockType = Types.BlockType.VALUE

var block: Block

@onready var _panel := %Panel
@onready var _line_edit := %LineEdit
@onready var snap_point := %SnapPoint
@onready var _input_switcher := %InputSwitcher
# Inputs
@onready var _text_input := %TextInput
@onready var _color_input := %ColorInput


func set_raw_input(raw_input):
	match block_type:
		Types.BlockType.COLOR:
			_color_input.color = raw_input
			_update_panel_bg_color(raw_input)
		_:
			_line_edit.text = raw_input


func get_raw_input():
	match block_type:
		Types.BlockType.COLOR:
			return _color_input.color
		_:
			return _line_edit.text


func _set_placeholder(new_placeholder: String) -> void:
	placeholder = new_placeholder

	if not is_node_ready():
		return

	_line_edit.placeholder_text = placeholder


func _ready():
	var stylebox = _panel.get_theme_stylebox("panel")
	stylebox.bg_color = Color.WHITE

	_set_placeholder(placeholder)

	if block == null:
		block = get_node_or_null(block_path)
	snap_point.block = block
	snap_point.block_type = block_type
	snap_point.variant_type = variant_type

	match block_type:
		Types.BlockType.COLOR:
			switch_input(_color_input)
		_:
			switch_input(_text_input)

	# Do something with block_type to restrict input


func get_snapped_block() -> Block:
	return snap_point.get_snapped_block()


func get_string() -> String:
	var snapped_block: ParameterBlock = get_snapped_block() as ParameterBlock
	if snapped_block:
		var generated_string = snapped_block.get_parameter_string()
		if Types.can_cast(snapped_block.variant_type, variant_type):
			return Types.cast(generated_string, snapped_block.variant_type, variant_type)
		else:
			push_warning("No cast from %s to %s; using '%s' verbatim" % [snapped_block, variant_type, generated_string])
			return generated_string

	var input = get_raw_input()

	match block_type:
		Types.BlockType.STRING:
			return "'%s'" % input.replace("\\", "\\\\").replace("'", "\\'")
		Types.BlockType.VECTOR2:
			return "Vector2(%s)" % input
		Types.BlockType.COLOR:
			return "Color%s" % str(input)
		_:
			return "%s" % input


func _on_line_edit_text_changed(new_text):
	modified.emit()


func switch_input(node: Node):
	for c in _input_switcher.get_children():
		c.visible = false

	node.visible = true


func _on_color_input_color_changed(color):
	_update_panel_bg_color(color)

	modified.emit()


func _update_panel_bg_color(new_color):
	var stylebox = _panel.get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = new_color
	_panel.add_theme_stylebox_override("panel", stylebox)
