@tool
extends BlockExtension

const OptionData = preload("res://addons/block_code/code_generation/option_data.gd")


func get_defaults_for_node(context_node: Node) -> Dictionary:
	var animation_player = context_node as AnimationPlayer

	if not animation_player:
		return {}

	var animation_list = animation_player.get_animation_list()

	return {"animation": OptionData.new(animation_list)}
