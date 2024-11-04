extends EditorInspectorPlugin

const BlockCodePlugin = preload("res://addons/block_code/block_code_plugin.gd")
const TxUtils := preload("res://addons/block_code/translation/utils.gd")


func _init():
	TxUtils.set_block_translation_domain(self)


func _can_handle(object):
	return object is BlockCode


func _parse_begin(object):
	var block_code := object as BlockCode

	var button := Button.new()
	button.text = tr("Open Block Script")
	button.pressed.connect(func(): BlockCodePlugin.main_panel.switch_block_code_node(block_code))

	var container := MarginContainer.new()
	container.add_theme_constant_override("margin_bottom", 10)
	container.add_child(button)

	add_custom_control(container)
