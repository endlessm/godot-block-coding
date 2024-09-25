@tool
extends BlockExtension

const OptionData = preload("res://addons/block_code/code_generation/option_data.gd")


func get_defaults() -> Dictionary:
	var animation_player = context_node as AnimationPlayer

	if not animation_player:
		return {}

	var animation_list = animation_player.get_animation_list()

	return {"animation": OptionData.new(animation_list)}


func _context_node_changed():
	var animation_player = context_node as AnimationPlayer

	if not animation_player:
		return

	animation_player.animation_list_changed.connect(_on_animation_list_changed)


func _on_animation_list_changed():
	_emit_changed()
