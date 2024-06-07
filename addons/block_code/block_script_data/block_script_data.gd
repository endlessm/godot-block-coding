@tool
class_name BlockScriptData
extends Resource

# signal source_code_dirty
# signal source_code_changed

@export var script_class_name: String:
	set = _set_script_class_name
@export var script_inherits: String:
	set = _set_script_inherits
@export var block_trees: SerializedBlockTreeNodeArray:
	set = _set_block_trees
@export var script_source_code: String:
	set = _set_script_source_code


func _init(p_script_class_name: String = "", p_script_inherits: String = "", p_block_trees: SerializedBlockTreeNodeArray = null, p_script_source_code: String = ""):
	print("_init!")
	script_class_name = p_script_class_name
	script_inherits = p_script_inherits
	block_trees = p_block_trees
	script_source_code = p_script_source_code


func _set_script_class_name(p_script_class_name: String):
	if script_class_name == p_script_class_name:
		return
	print("script_class_name changed!")
	script_class_name = p_script_class_name
	# source_code_dirty.emit()
	emit_changed()


func _set_script_inherits(p_script_inherits: String):
	if script_inherits == p_script_inherits:
		return
	print("script_inherits changed!")
	script_inherits = p_script_inherits
	# source_code_dirty.emit()
	emit_changed()


func _set_block_trees(p_block_trees: SerializedBlockTreeNodeArray):
	if block_trees == p_block_trees:
		return
	print("block_trees changed!")
	block_trees = p_block_trees
	# source_code_dirty.emit()
	emit_changed()


func _set_script_source_code(p_script_source_code: String):
	if script_source_code == p_script_source_code:
		return
	print("script_source_code changed!")
	script_source_code = p_script_source_code
	emit_changed()


func say_hello():
	print(script_source_code)
