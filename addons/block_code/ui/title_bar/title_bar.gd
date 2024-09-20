@tool
extends MarginContainer

const BlockCodePlugin = preload("res://addons/block_code/block_code_plugin.gd")

signal node_name_changed(node_name: String)

@onready var _context := BlockEditorContext.get_default()

@onready var _block_code_icon = load("res://addons/block_code/block_code_node/block_code_node.svg") as Texture2D
@onready var _editor_inspector: EditorInspector = EditorInterface.get_inspector()
@onready var _node_option_button: OptionButton = %NodeOptionButton


func _ready():
	_context.changed.connect(_on_context_changed)
	_node_option_button.connect("item_selected", _on_node_option_button_item_selected)


func _on_context_changed():
	# TODO: We should listen for property changes in all BlockCode nodes and
	#       their parents. As a workaround for the UI displaying stale data,
	#       we'll crudely update the list of BlockCode nodes whenever the
	#       selection changes.

	_update_node_option_button_items()

	var select_index = _get_block_script_index(_context.block_script)
	if _node_option_button.selected != select_index:
		_node_option_button.select(select_index)


func _update_node_option_button_items():
	_node_option_button.clear()

	var scene_root = EditorInterface.get_edited_scene_root()

	if not scene_root:
		return

	for block_code in BlockCodePlugin.list_block_code_nodes_for_node(scene_root, true):
		if not BlockCodePlugin.is_block_code_editable(block_code):
			continue

		var node_item_index = _node_option_button.item_count
		var node_label = "{name} ({type})".format({"name": scene_root.get_path_to(block_code).get_concatenated_names(), "type": block_code.block_script.script_inherits})
		_node_option_button.add_item(node_label)
		_node_option_button.set_item_icon(node_item_index, _block_code_icon)
		_node_option_button.set_item_metadata(node_item_index, block_code)

	_node_option_button.disabled = _node_option_button.item_count == 0


func _get_block_script_index(block_script: BlockScriptSerialization) -> int:
	for index in range(_node_option_button.item_count):
		var block_code_node = _node_option_button.get_item_metadata(index)
		if block_code_node.block_script == block_script:
			return index
	return -1


func _on_node_option_button_item_selected(index):
	var block_code_node = _node_option_button.get_item_metadata(index) as BlockCode
	_context.block_code_node = block_code_node
