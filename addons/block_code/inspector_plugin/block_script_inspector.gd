extends EditorInspectorPlugin


func _can_handle(object):
	return object is BlockCode


func _parse_begin(object):
	var block_code := object as BlockCode

	var button := Button.new()
	button.text = "Open Block Script"
	button.pressed.connect(func(): BlockCodePlugin.main_panel.switch_script(block_code))

	var container := MarginContainer.new()
	container.add_theme_constant_override("margin_bottom", 10)
	container.add_child(button)

	add_custom_control(container)
