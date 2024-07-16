class_name VariableResource
extends Resource

@export var var_name: String
@export var var_type: Variant.Type


func _init(p_var_name: String = "", p_var_type: Variant.Type = TYPE_NIL):
	var_name = p_var_name
	var_type = p_var_type
