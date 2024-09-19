@tool
extends MarginContainer

const OptionData = preload("res://addons/block_code/code_generation/option_data.gd")
const Types = preload("res://addons/block_code/types/types.gd")

signal modified

@export var placeholder: String = "Parameter":
	set = _set_placeholder

@export var variant_type: Variant.Type = TYPE_STRING
@export var block_type: Types.BlockType = Types.BlockType.VALUE
@export var option_data: OptionData:
	set = _set_option_data

var default_value: Variant

@onready var _panel := %Panel
@onready var snap_point := %SnapPoint
@onready var _input_switcher := %InputSwitcher

## Inputs
# Text
@onready var _text_input := %TextInput
@onready var _line_edit := %LineEdit
# Color
@onready var _color_input := %ColorInput
# Option Dropdown
@onready var _option_input := %OptionInput
# Vector2
@onready var _vector2_input := %Vector2Input
@onready var _x_line_edit := %XLineEdit
@onready var _y_line_edit := %YLineEdit
# Bool
@onready var _bool_input := %BoolInput
@onready var _bool_input_option := %BoolInputOption

# Used to submit the text when losing focus:
@onready var _last_submitted_text = {
	_line_edit: "",
	_x_line_edit: "",
	_y_line_edit: "",
}


## Sets the value using [param raw_input], which could be one of a variety of types
## depending on [member variant_type]. The value could also be a [Block], in which
## case the block will be snapped to the control, replacing its editor.
func set_raw_input(raw_input: Variant):
	if raw_input is Block:
		snap_point.replace_snapped_block(raw_input)
		# Continue from here to reset the editor to default values
		raw_input = null

	if option_data:
		_update_option_input(raw_input)
		return

	if raw_input == null:
		raw_input = default_value

	match variant_type:
		TYPE_COLOR:
			_color_input.color = raw_input
			_update_panel_bg_color(raw_input)
		TYPE_VECTOR2:
			# Rounding because floats are doubles by default but Vector2s have single components
			_x_line_edit.text = ("%.4f" % raw_input.x).rstrip("0").rstrip(".") if raw_input != null else ""
			_y_line_edit.text = ("%.4f" % raw_input.y).rstrip("0").rstrip(".") if raw_input != null else ""
		TYPE_BOOL:
			_bool_input_option.select(1 if raw_input else 0)
		TYPE_NIL:
			_line_edit.text = raw_input if raw_input != null else ""
		_:
			_line_edit.text = str(raw_input) if raw_input != null else ""

	_last_submitted_text[_line_edit] = _line_edit.text
	_last_submitted_text[_x_line_edit] = _x_line_edit.text
	_last_submitted_text[_y_line_edit] = _y_line_edit.text


## Gets the value, which could be one of a variety of types depending on
## [member variant_type]. The value could also be a [Block], if one was previously
## snapped to the control.
func get_raw_input() -> Variant:
	var snapped_block = snap_point.get_snapped_block()

	if snapped_block:
		return snapped_block

	if option_data:
		return _option_input.get_selected_metadata()

	match variant_type:
		TYPE_COLOR:
			return _color_input.color
		TYPE_VECTOR2:
			return Vector2(float(_x_line_edit.text), float(_y_line_edit.text))
		TYPE_BOOL:
			return bool(_bool_input_option.selected)
		TYPE_INT:
			return null if _line_edit.text == "" else int(_line_edit.text)
		TYPE_FLOAT:
			return null if _line_edit.text == "" else float(_line_edit.text)
		TYPE_STRING_NAME:
			return StringName(_line_edit.text)
		TYPE_NIL:
			return _line_edit.text
		_:
			return _line_edit.text


func _set_option_data(new_option_data: OptionData) -> void:
	option_data = new_option_data

	if not is_node_ready():
		return

	# If options are being provided, you can't snap blocks.
	snap_point.visible = not option_data

	_update_option_input()


func _set_placeholder(new_placeholder: String) -> void:
	placeholder = new_placeholder

	if not is_node_ready():
		return

	_line_edit.placeholder_text = placeholder
	_input_switcher.tooltip_text = placeholder
	_option_input.tooltip_text = placeholder


func _ready():
	var stylebox = _panel.get_theme_stylebox("panel")
	stylebox.bg_color = Color.WHITE

	_set_placeholder(placeholder)
	_set_option_data(option_data)

	snap_point.block_type = block_type
	snap_point.variant_type = variant_type

	_update_visible_input()

	if default_value:
		set_raw_input(default_value)


func get_snapped_block() -> Block:
	return snap_point.get_snapped_block()


func _validate_and_submit_edit_text(line_edit: Node, type: Variant.Type):
	if _last_submitted_text[line_edit] == line_edit.text:
		return
	match type:
		TYPE_FLOAT:
			if not line_edit.text.is_valid_float():
				line_edit.text = _last_submitted_text[line_edit]
				return
		TYPE_INT:
			if not line_edit.text.is_valid_int():
				line_edit.text = _last_submitted_text[line_edit]
				return
	_last_submitted_text[line_edit] = line_edit.text

	modified.emit()


func _on_line_edit_text_submitted(_new_text):
	_validate_and_submit_edit_text(_line_edit, variant_type)


func _on_line_edit_focus_exited():
	_validate_and_submit_edit_text(_line_edit, variant_type)


func _on_x_line_edit_text_submitted(_new_text):
	_validate_and_submit_edit_text(_x_line_edit, TYPE_FLOAT)


func _on_x_line_edit_focus_exited():
	_validate_and_submit_edit_text(_x_line_edit, TYPE_FLOAT)


func _on_y_line_edit_text_submitted(_new_text):
	_validate_and_submit_edit_text(_y_line_edit, TYPE_FLOAT)


func _on_y_line_edit_focus_exited():
	_validate_and_submit_edit_text(_y_line_edit, TYPE_FLOAT)


func _update_visible_input():
	if snap_point.has_snapped_block():
		_switch_input(null)
	elif option_data:
		_switch_input(_option_input)
	else:
		match variant_type:
			TYPE_COLOR:
				_switch_input(_color_input)
			TYPE_VECTOR2:
				_switch_input(_vector2_input)
			TYPE_BOOL:
				_switch_input(_bool_input)
			_:
				_switch_input(_text_input)


func _switch_input(node: Node):
	for c in _input_switcher.get_children():
		c.visible = c == node
	_panel.visible = node not in [_option_input]


func _update_option_input(current_value: Variant = null):
	if not option_data:
		return

	if current_value is OptionData:
		# Temporary hack: previously, the value was stored as an OptionData
		# object with a list of items and a "selected" property. Instead,
		# convert that value to the corresponding item.
		current_value = current_value.items[current_value.selected]

	if current_value == null:
		current_value = _option_input.get_selected_metadata()

	_option_input.clear()

	var selected_item_index: int = -1

	for item in option_data.items:
		var item_index = _option_input.item_count
		var option_label = item.capitalize() if item is String else str(item)
		_option_input.add_item(option_label)
		_option_input.set_item_tooltip(item_index, item)
		_option_input.set_item_metadata(item_index, item)
		if item == current_value:
			selected_item_index = item_index

	if selected_item_index == -1 and current_value:
		# If the current value is not in the default list of options, add it
		# and select it.
		if _option_input.item_count > 0:
			_option_input.add_separator()
		var item_index = _option_input.item_count
		var option_label = current_value.capitalize() if current_value is String else str(current_value)
		_option_input.add_item(option_label)
		_option_input.set_item_tooltip(item_index, current_value)
		_option_input.set_item_metadata(item_index, current_value)
		selected_item_index = item_index
	elif _option_input.item_count == 0:
		var item_index = _option_input.item_count
		_option_input.add_item("<%s>" % placeholder)
		_option_input.set_item_disabled(item_index, true)
		selected_item_index = item_index
	elif selected_item_index == -1:
		selected_item_index = option_data.selected

	_option_input.select(selected_item_index)


func _on_color_input_color_changed(color):
	_update_panel_bg_color(color)
	modified.emit()


func _update_panel_bg_color(new_color):
	var stylebox = _panel.get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = new_color
	_panel.add_theme_stylebox_override("panel", stylebox)


func _on_option_input_item_selected(index):
	modified.emit()


func _on_snap_point_snapped_block_changed(block):
	_update_visible_input()
