extends Resource

const Types = preload("res://addons/block_code/types/types.gd")

var name: StringName
var type: Types.BlockType
var description: String
var category: String

var label_template: String
var code_template: String
var defaults: Dictionary = {}

## Only for blocks of type Types.ENTRY. If non-empty, this block defines a
## callback that will be connected to the signal with this name.
var signal_name: String = ""


func _init(p_name: StringName, p_type: Types.BlockType):
	name = p_name
	type = p_type
