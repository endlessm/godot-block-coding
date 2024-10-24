@tool
extends Resource

const BlockSerialization = preload("res://addons/block_code/serialization/block_serialization.gd")

@export var name: StringName:
	set = _set_name
@export var children: Array[BlockSerialization]
@export var arguments: Dictionary  # String, ValueBlockSerialization


func _init(p_name: StringName = &"", p_children: Array[BlockSerialization] = [], p_arguments: Dictionary = {}):
	name = p_name
	children = p_children
	arguments = p_arguments


# Block name backwards compatibility handling.
const _renamed_blocks: Dictionary = {}


func _set_name(value):
	var new_name = _renamed_blocks.get(value)
	if new_name:
		print("Migrating block %s to new name %s" % [value, new_name])
		name = new_name
		if Engine.is_editor_hint():
			EditorInterface.mark_scene_as_unsaved()
	else:
		name = value
