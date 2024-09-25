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
## as [method get_defaults].[br]
## [br]
## In some cases, an extension may need to monitor the scene to determine if it
## has changed. To achieve this, override [method _context_node_changed] to
## connect the relevant signals, and call [method _emit_changed] when a
## significant change has occurred.
class_name BlockExtension
extends RefCounted

signal changed

var context_node: Node:
	set(value):
		if context_node != value:
			context_node = value
			_context_node_changed()


## Called when the value of context_node changes. Use this for connecting
## signals to monitor for changes.
func _context_node_changed():
	pass


## Generate a set of defaults for this block extension based on the current
## context. The return value will be merged with the defaults specified in the
## static block definition.
func get_defaults() -> Dictionary:
	return get_defaults_for_node(context_node)


## @deprecated: Use [method get_defaults] instead.
func get_defaults_for_node(context_node: Node) -> Dictionary:
	return {}


## Emit the "changed" signal. Use this when an event has occurred which may
## cause [method get_defaults] to return a different value.
func _emit_changed():
	changed.emit()
