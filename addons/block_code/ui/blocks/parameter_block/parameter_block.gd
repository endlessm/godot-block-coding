@tool
class_name ParameterBlock
extends Block

const Constants = preload("res://addons/block_code/ui/constants.gd")
const Util = preload("res://addons/block_code/ui/util.gd")
const ParameterOutput = preload("res://addons/block_code/ui/blocks/utilities/parameter_output/parameter_output.gd")

@onready var _background := $Background
@onready var _panel := $Panel

var args_to_add_after_format: Dictionary  # Only used when loading
var spawned_by: ParameterOutput

var _panel_normal: StyleBox
var _panel_focus: StyleBox


func _ready():
	super()

	if not definition == null and definition.variant_type == Variant.Type.TYPE_BOOL:
		_background.visible = true
		_background.background_variant = _background.POINTED
		_background.color = color
		_panel.visible = false
	else:
		_panel_normal = _panel.get_theme_stylebox("panel").duplicate()
		_panel_normal.bg_color = color
		_panel_normal.border_color = color.darkened(0.2)

		_panel_focus = _panel.get_theme_stylebox("panel").duplicate()
		_panel_focus.bg_color = color
		_panel_focus.border_color = Constants.FOCUS_BORDER_COLOR

		if not Util.node_is_part_of_edited_scene(self):
			_panel.add_theme_stylebox_override("panel", _panel_normal)


func _on_drag_drop_area_drag_started(offset: Vector2) -> void:
	_drag_started(offset)


static func get_block_class():
	return "ParameterBlock"


static func get_scene_path():
	return "res://addons/block_code/ui/blocks/parameter_block/parameter_block.tscn"


func _on_focus_entered():
	if not definition == null and not definition.variant_type == Variant.Type.TYPE_BOOL:
		_panel.add_theme_stylebox_override("panel", _panel_focus)


func _on_focus_exited():
	if not definition == null and not definition.variant_type == Variant.Type.TYPE_BOOL:
		_panel.add_theme_stylebox_override("panel", _panel_normal)
