@tool
class_name SimpleScoring
extends Node2D

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")
const Types = preload("res://addons/block_code/types/types.gd")

@export var score: int:
	set = _set_score

var _score_label: Label


func _create_score_label():
	if _score_label:
		return

	_score_label = Label.new()

	_score_label.set_size(Vector2(477, 1080))
	_score_label.pivot_offset = Vector2(240, 176)
	#label.size_flags_horizontal = Control.SizeFlags.SIZE_EXPAND_FILL
	#label.size_flags_vertical = Control.SizeFlags.SIZE_FILL
	_score_label.add_theme_font_size_override("font_size", 200)
	_score_label.text = "0"
	_score_label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER

	add_child(_score_label)


func _ready():
	simple_setup()


func simple_setup():
	add_to_group("hud", true)
	_create_score_label()
	_update_label(score)


func get_custom_class():
	return "SimpleScoring"


func _set_score(new_score):
	score = new_score
	_update_label(score)


func _update_label(score):
	if not is_node_ready():
		return
	_score_label.text = str(score)


static func setup_custom_blocks():
	var _class_name = "SimpleScoring"
	var block_list: Array[BlockDefinition] = []

	var block_definition: BlockDefinition = BlockDefinition.new()
	block_definition.name = &"simplescoring_set_score"
	block_definition.target_node_class = _class_name
	block_definition.category = "Info | Score"
	block_definition.type = Types.BlockType.STATEMENT
	block_definition.display_template = "set score to {score: INT}"
	block_definition.code_template = "score = {score}"
	block_list.append(block_definition)

	block_definition = BlockDefinition.new()
	block_definition.name = &"simplescoring_change_score"
	block_definition.target_node_class = _class_name
	block_definition.category = "Info | Score"
	block_definition.type = Types.BlockType.STATEMENT
	block_definition.display_template = "change score by {score: INT}"
	block_definition.code_template = "score += {score}"
	block_list.append(block_definition)

	BlocksCatalog.add_custom_blocks(_class_name, block_list)
