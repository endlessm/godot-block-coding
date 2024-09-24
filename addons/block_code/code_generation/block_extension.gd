@tool
## Block extensions interface.
##
## A BlockExtension provides additional, context-sensitive information for the
## user interface of a particular type of block. An instance of BlockExtension
## belongs to a specific [Block] in the block canvas, but an extension does not
## have direct access to its block. Instead, it can use the [member context_node]
## property to draw information about the scene.[br]
## [br]
## To customize the user interface for a block, override public functions such
## as [method get_defaults].
class_name BlockExtension
extends RefCounted

var context_node: Node:
	set(value):
		context_node = value


## Generate a set of defaults for this block extension based on the current
## context. The return value will be merged with the defaults specified in the
## static block definition.
func get_defaults() -> Dictionary:
	return get_defaults_for_node(context_node)


## @deprecated: Use [method get_defaults] instead.
func get_defaults_for_node(context_node: Node) -> Dictionary:
	return {}
