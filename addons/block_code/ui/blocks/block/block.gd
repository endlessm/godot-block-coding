@tool
class_name Block
extends MarginContainer

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")

signal drag_started(block: Block, offset: Vector2)
signal modified

## Color of block (optionally used to draw block color)
@export var color: Color = Color(1., 1., 1.)

## Whether the parameter inputs inside the block can be edited.
@export var editable: bool = true:
	set = _set_editable

# FIXME Note: This used to be a NodePath. There is a bug in Godot 4.2 that causes the
# reference to not be set properly when the node is duplicated. Since we don't
# use the Node duplicate function anymore, this is okay.
# https://github.com/godotengine/godot/issues/82670
## The next block in the line of execution (can be null if end)
@export var bottom_snap: SnapPoint = null

## Snap point that holds blocks that should be nested under this block
@export var child_snap: SnapPoint = null

## The resource containing the definition of the block
@export var template_editor: TemplateEditor = null

## The scope of the block (statement of matching entry block)
@export var scope: String = ""

## The resource containing the definition of the block
@export var definition: BlockDefinition:
	set(value):
		var is_changed := definition != value
		if definition and is_changed:
			definition.changed.disconnect(_on_definition_changed)
		definition = value
		if definition and is_changed:
			definition.changed.connect(_on_definition_changed)
		if is_changed:
			_on_definition_changed()

## Whether the block can be deleted by the Delete key.
var can_delete: bool = true

var _block_extension: BlockExtension

var _block_canvas: Node

@onready var _context := BlockEditorContext.get_default()


func _ready():
	focus_mode = FocusMode.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_entered.connect(_block_on_focus_entered)
	focus_exited.connect(_block_on_focus_exited)
	_on_definition_changed()


func _set_editable(value) -> void:
	editable = value
	template_editor.editable = value


func _block_on_focus_entered():
	z_index = 1
	if bottom_snap:
		bottom_snap.z_index = -1
	if child_snap:
		child_snap.z_index = -1


func _block_on_focus_exited():
	z_index = 0
	if bottom_snap:
		bottom_snap.z_index = 0
	if child_snap:
		child_snap.z_index = 0


func _on_definition_changed():
	_block_extension = null
	_update_template_editor()


func set_parameter_values_on_ready(raw_values: Dictionary):
	await ready
	set_parameter_values(raw_values)


func set_parameter_values(raw_values: Dictionary):
	template_editor.set_parameter_values(raw_values)


func get_parameter_values() -> Dictionary:
	return template_editor.get_parameter_values()


## Use the current BlockEditorContext components
func refresh_context():
	if _context and _block_extension:
		_block_extension.context_node = _context.parent_node


func _update_template_editor():
	if template_editor == null:
		return

	template_editor.format_string = _get_format_string()
	template_editor.parameter_defaults = _get_parameter_defaults()
	if not template_editor.modified.is_connected(_on_template_editor_modified):
		template_editor.modified.connect(_on_template_editor_modified)
	if not template_editor.drag_started.is_connected(_on_template_editor_drag_started):
		template_editor.drag_started.connect(_on_template_editor_drag_started)


func _on_template_editor_modified():
	modified.emit()


func _on_template_editor_drag_started(offset: Vector2):
	_drag_started(offset)


func _get_format_string() -> String:
	if not definition:
		return ""

	if definition.property_name and TranslationServer.has_method(&"get_or_add_domain"):
		var domain: TranslationDomain = TranslationServer.get_or_add_domain("godot.properties")
		var translated_property: String = domain.translate(definition.property_name.capitalize())
		# TODO: Ideally we should be also passing the context. See:
		# https://github.com/godotengine/godot/blob/978b38797ba8e8757592f21101e32e364d60662d/editor/editor_property_name_processor.cpp#L90
		return tr(definition.display_template) % translated_property.to_lower()

	return tr(definition.display_template)


func _get_parameter_defaults() -> Dictionary:
	if not definition:
		return {}

	var block_extension := _get_or_create_block_extension()

	if not block_extension:
		return definition.defaults

	return block_extension.get_defaults().merged(definition.defaults)


func _get_or_create_block_extension() -> BlockExtension:
	if _block_extension:
		return _block_extension

	if not definition:
		return null

	if not _context:
		return null

	_block_extension = definition.create_block_extension()

	if not _block_extension:
		return null

	_block_extension.context_node = _context.parent_node
	_block_extension.changed.connect(_on_block_extension_changed)

	return _block_extension


func _on_block_extension_changed():
	_update_template_editor()


func _gui_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_DELETE:
				# Always accept the Delete key so it doesn't propagate to the
				# BlockCode node in the scene tree.
				accept_event()
				confirm_delete()
			elif event.ctrl_pressed and not event.shift_pressed and not event.alt_pressed and not event.meta_pressed:
				# Should not accept when other keys are pressed
				if event.keycode == KEY_D:
					accept_event()
					confirm_duplicate()


func confirm_delete():
	if not can_delete:
		return

	var dialog := ConfirmationDialog.new()
	var num_blocks = _count_child_blocks(self) + 1
	# FIXME: Maybe this should use block_name or label, but that
	# requires one to be both unique and human friendly.
	if num_blocks > 1:
		dialog.dialog_text = "Delete %d blocks?" % num_blocks
	else:
		dialog.dialog_text = "Delete block?"
	dialog.confirmed.connect(remove_from_tree)
	EditorInterface.popup_dialog_centered(dialog)


func confirm_duplicate():
	if not can_delete:
		return

	var new_block: Block = _context.block_script.instantiate_block(definition)

	var new_parent: Node = get_parent()
	while not new_parent.name == "Window":
		new_parent = new_parent.get_parent()

	if not _block_canvas:
		_block_canvas = get_parent()
		while not _block_canvas.name == "BlockCanvas":
			_block_canvas = _block_canvas.get_parent()

	new_parent.add_child(new_block)
	new_block.global_position = global_position + (Vector2(100, 50) * new_parent.scale)

	_copy_snapped_blocks(self, new_block)

	_block_canvas.reconnect_block.emit(new_block)

	modified.emit()


func remove_from_tree():
	var parent = get_parent()
	if parent:
		parent.remove_child(self)
	queue_free()
	modified.emit()


static func get_block_class():
	push_error("Unimplemented.")


static func get_scene_path():
	push_error("Unimplemented.")


func _drag_started(offset: Vector2 = Vector2.ZERO):
	drag_started.emit(self, offset)


func disconnect_signals():
	var connections: Array = drag_started.get_connections()
	for c in connections:
		drag_started.disconnect(c.callable)


func _to_string():
	return "<{block_class}:{block_name}#{rid}>".format({"block_name": definition.name if definition else "", "block_class": get_block_class(), "rid": get_instance_id()})


func _get_tooltip(at_position: Vector2) -> String:
	if not definition:
		return ""

	var description_tx := tr(definition.description)
	if definition.variant_type == Variant.Type.TYPE_NIL:
		return description_tx

	return "{description}\n\n{type_field} [b]{type}[/b]".format({"description": description_tx, "type_field": tr("Type:"), "type": type_string(definition.variant_type)})


func _make_custom_tooltip(for_text) -> Control:
	var tooltip = preload("res://addons/block_code/ui/tooltip/tooltip.tscn").instantiate()
	tooltip.text = for_text
	return tooltip


func _count_child_blocks(node: Node) -> int:
	var count = 0

	for child in node.get_children():
		if child is SnapPoint and child.has_snapped_block():
			count += 1

		if child is Container:
			count += _count_child_blocks(child)

	return count


func _copy_snapped_blocks(copy_from: Node, copy_to: Node):
	var copy_to_child: Node
	var child_index := 0
	var maximum_count := copy_to.get_child_count()

	for copy_from_child in copy_from.get_children():
		if child_index + 1 > maximum_count:
			return

		copy_to_child = copy_to.get_child(child_index)
		child_index += 1

		if copy_from_child is SnapPoint and copy_from_child.has_snapped_block():
			copy_to_child.add_child(_context.block_script.instantiate_block(copy_from_child.snapped_block.definition))
			_block_canvas.reconnect_block.emit(copy_to_child.snapped_block)
		elif copy_from_child.name.begins_with("ParameterInput"):
			var raw_input = copy_from_child.get_raw_input()

			if not raw_input is Block:
				copy_to_child.set_raw_input(raw_input)

		if copy_from_child is Container:
			_copy_snapped_blocks(copy_from_child, copy_to_child)
