@tool
class_name Tooltip
extends RichTextLabel
## Rich-text control for block tooltips that matches the built-in inspector's tooltips' font styles

const Util = preload("res://addons/block_code/ui/util.gd")


func override_font(font_name: StringName, editor_font_name: StringName) -> Font:
	var font = get_theme_font(editor_font_name, &"EditorFonts")
	add_theme_font_override(font_name, font)
	return font


func override_fonts():
	# Set fonts to match documentation tooltips in inspector
	override_font(&"normal_font", &"doc")
	override_font(&"mono_font", &"doc_source")
	override_font(&"bold_font", &"doc_bold")
	var italics = override_font(&"italics_font", &"doc_italic")

	# No doc_ style for bold italic; fake it by emboldening the italic style
	var bold_italics = FontVariation.new()
	bold_italics.set_base_font(italics)
	bold_italics.set_variation_embolden(1.2)
	add_theme_font_override(&"bold_italics_font", bold_italics)


func _ready():
	if not Util.node_is_part_of_edited_scene(self):
		override_fonts()
