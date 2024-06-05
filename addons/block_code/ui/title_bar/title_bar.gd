@tool
class_name TitleBar
extends MarginContainer

signal node_name_changed(node_name: String)

@onready var _node_name := %NodeName
@onready var _class_name := %ClassName


func bsd_selected(bsd: BlockScriptData):
	_node_name.text = bsd.script_class_name
	_class_name.text = bsd.script_inherits


#func node_selected(node_data: NodeData):
#_node_name.text = node_data.node_name
#_class_name.text = node_data.node_class_name


func _on_node_name_text_changed(new_text: String):
	#node_name_changed.emit(new_text)
	pass
