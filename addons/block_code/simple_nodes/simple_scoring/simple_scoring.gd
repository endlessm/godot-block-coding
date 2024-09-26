@tool
class_name SimpleScoring
extends CanvasLayer

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")
const Types = preload("res://addons/block_code/types/types.gd")

@export var score_left: int:
	set = _set_score_left

@export var score_right: int:
	set = _set_score_right

var _score_labels: Dictionary

const _POSITIONS_FOR_PLAYER = {
	"1": "left",
	"2": "right",
}


func _create_score_label(player: String) -> Label:
	var label := Label.new()

	var x_pos: int
	match player:
		"left":
			x_pos = 240
		"right":
			x_pos = 1200
		_:
			push_error('Unrecognized SimpleScoring player "%s"' % player)

	label.name = &"Player%sScore" % player.capitalize()
	label.set_size(Vector2(477, 1080))
	label.set_position(Vector2(x_pos, 0))
	label.pivot_offset = Vector2(240, 176)
	label.size_flags_horizontal = Control.SizeFlags.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SizeFlags.SIZE_FILL
	label.add_theme_font_size_override("font_size", 200)
	label.text = "0"
	label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER

	return label


func _ready():
	simple_setup()


func simple_setup():
	add_to_group("hud", true)

	var left_label := _create_score_label("left")
	_score_labels["left"] = left_label
	_update_label("left", score_left)
	add_child(left_label)

	var right_label := _create_score_label("right")
	_score_labels["right"] = right_label
	_update_label("right", score_right)
	add_child(right_label)


func get_custom_class():
	return "SimpleScoring"


func _set_score_left(new_score_left):
	score_left = new_score_left
	if score_left and is_node_ready():
		_update_label("left", score_left)


func _set_score_right(new_score_right):
	score_right = new_score_right
	if score_right and is_node_ready():
		_update_label("right", score_right)


func _update_label(player, score):
	_score_labels[player].text = str(score)


## Sets the score for one player.
func set_player_score(player: String, score: int):
	var text = _score_labels[player].text
	if str(score) != text:
		_score_labels[player].text = str(score)


static func setup_custom_blocks():
	var _class_name = "SimpleScoring"
	var block_list: Array[BlockDefinition] = []

	for player in _POSITIONS_FOR_PLAYER:
		var block_definition: BlockDefinition = BlockDefinition.new()
		block_definition.name = &"simplescoring_set_score_player_%s" % player
		block_definition.target_node_class = _class_name
		block_definition.category = "Info | Score"
		block_definition.type = Types.BlockType.STATEMENT
		block_definition.display_template = "set player %s score to {score: INT}" % player
		block_definition.code_template = "score_%s = {score}" % _POSITIONS_FOR_PLAYER[player]
		block_list.append(block_definition)

		block_definition = BlockDefinition.new()
		block_definition.name = &"simplescoring_change_score_player_%s" % player
		block_definition.target_node_class = _class_name
		block_definition.category = "Info | Score"
		block_definition.type = Types.BlockType.STATEMENT
		block_definition.display_template = "change player %s score by {score: INT}" % player
		block_definition.code_template = "score_%s += {score}" % _POSITIONS_FOR_PLAYER[player]
		block_list.append(block_definition)

	BlocksCatalog.add_custom_blocks(_class_name, block_list)
