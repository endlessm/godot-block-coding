extends Resource

@export var name: StringName
@export var arguments: Dictionary  # String, ValueBlockSerialization


func _init(p_name: StringName = &"", p_arguments: Dictionary = {}):
	name = p_name
	arguments = p_arguments
