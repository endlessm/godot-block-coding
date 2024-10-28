@tool
extends Resource

const BlockSerialization = preload("res://addons/block_code/serialization/block_serialization.gd")

@export var name: StringName:
	set = _set_name
@export var children: Array[BlockSerialization]
@export var arguments: Dictionary:  # String, ValueBlockSerialization
	set = _set_arguments


func _init(p_name: StringName = &"", p_children: Array[BlockSerialization] = [], p_arguments: Dictionary = {}):
	name = p_name
	children = p_children
	arguments = p_arguments


# Block name and arguments backwards compatibility handling.
const _renamed_blocks: Dictionary = {
	&"simplespawner_set_spawn_frequency": &"simplespawner_set_spawn_period",
}


func _set_name(value):
	var new_name = _renamed_blocks.get(value)
	if new_name:
		print("Migrating block %s to new name %s" % [value, new_name])
		name = new_name
		if Engine.is_editor_hint():
			EditorInterface.mark_scene_as_unsaved()
	else:
		name = value


const _renamed_arguments: Dictionary = {
	&"simplespawner_set_spawn_period":
	{
		"new_frequency": "new_period",
	},
}


func _set_arguments(value):
	if not value is Dictionary:
		return

	var renamed_args = _renamed_arguments.get(name)
	if not renamed_args:
		# Try with the new block name if it hasn't been migrated yet.
		var new_block_name = _renamed_blocks.get(name)
		if new_block_name:
			renamed_args = _renamed_arguments.get(new_block_name)

	if renamed_args:
		var changed: bool = false
		value = value.duplicate()
		for old_arg in renamed_args.keys():
			if not old_arg in value:
				continue

			var new_arg = renamed_args[old_arg]
			print("Migrating block %s argument %s to new name %s" % [name, old_arg, new_arg])
			value[new_arg] = value[old_arg]
			value.erase(old_arg)
			changed = true

		if changed and Engine.is_editor_hint():
			EditorInterface.mark_scene_as_unsaved()

	arguments = value
