@tool
class_name Block
extends MarginContainer

signal drag_started(block: Block)
signal modified

## Label of block (optionally used to draw block labels)
@export var label: String = ""

## Color of block (optionally used to draw block color)
@export var color: Color = Color(1., 1., 1.)

## Category to add the block to
@export var category: String

## The next block in the line of execution (can be null if end)
@export var bottom_snap: SnapPoint = null

## Snap point that holds blocks that should be nested under this block
@export var child_snap: SnapPoint = null

## The scope of the block (statement of matching entry block)
@export var scope: String = ""

## The resource containing the block properties and the snapped blocks
@export var block_resource: BlockResource


func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE


static func get_block_class():
	push_error("Unimplemented.")


static func get_scene_path():
	push_error("Unimplemented.")


func _drag_started():
	drag_started.emit(self)


func disconnect_signals():
	var connections: Array = drag_started.get_connections()
	for c in connections:
		drag_started.disconnect(c.callable)


func _to_string():
	return "<{block_class}:{block_name}#{rid}>".format({"block_name": block_resource.block_name, "block_class": get_block_class(), "rid": get_instance_id()})


func _make_custom_tooltip(for_text) -> Control:
	var tooltip = preload("res://addons/block_code/ui/tooltip/tooltip.tscn").instantiate()
	tooltip.text = for_text
	return tooltip
