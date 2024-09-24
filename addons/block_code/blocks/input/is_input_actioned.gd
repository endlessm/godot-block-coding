@tool
extends BlockExtension

const OptionData = preload("res://addons/block_code/code_generation/option_data.gd")


func get_defaults() -> Dictionary:
	var inputmap_actions = _get_inputmap_actions()
	return {"action_name": OptionData.new(inputmap_actions)}


static func _get_inputmap_actions() -> Array[StringName]:
	var inputmap_actions: Array[StringName]

	var editor_input_actions: Dictionary = {}
	var editor_input_action_deadzones: Dictionary = {}
	if Engine.is_editor_hint():
		var actions := InputMap.get_actions()
		for action in actions:
			if action.begins_with("spatial_editor"):
				var events := InputMap.action_get_events(action)
				editor_input_actions[action] = events
				editor_input_action_deadzones[action] = InputMap.action_get_deadzone(action)

	InputMap.load_from_project_settings()

	inputmap_actions = InputMap.get_actions()

	if Engine.is_editor_hint():
		for action in editor_input_actions.keys():
			InputMap.add_action(action, editor_input_action_deadzones[action])
			for event in editor_input_actions[action]:
				InputMap.action_add_event(action, event)

	return inputmap_actions
