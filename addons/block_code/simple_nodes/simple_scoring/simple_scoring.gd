@tool
class_name SimpleScoring
extends CanvasLayer

@export var score_left: int:
	set = _set_score_left

@export var score_right: int:
	set = _set_score_right

@onready var _score_labels = {
	"left": %PlayerLeftScore,
	"right": %PlayerRightScore,
}

const _POSITIONS_FOR_PLAYER = {
	"1": "left",
	"2": "right",
}


func get_custom_class():
	return "SimpleScoring"


func _set_score_left(new_score_left):
	score_left = new_score_left
	if not is_node_ready():
		await ready
	if score_left:
		_update_label("left", score_left)


func _set_score_right(new_score_right):
	score_right = new_score_right
	if not is_node_ready():
		await ready
	if score_right:
		_update_label("right", score_right)


func _update_label(player, score):
	_score_labels[player].text = str(score)


## Sets the score for one player.
func set_player_score(player: String, score: int):
	var text = _score_labels[player].text
	if str(score) != text:
		_score_labels[player].text = str(score)


static func get_custom_blocks() -> Array[Block]:
	var b: Block
	var block_list: Array[Block] = []

	for player in _POSITIONS_FOR_PLAYER:
		b = CategoryFactory.BLOCKS["statement_block"].instantiate()
		b.block_type = Types.BlockType.EXECUTE
		b.block_format = "Set player %s score to {score: INT}" % player
		b.statement = "score_%s = {score}" % _POSITIONS_FOR_PLAYER[player]
		b.category = "Info | Score"
		block_list.append(b)

		b = CategoryFactory.BLOCKS["statement_block"].instantiate()
		b.block_type = Types.BlockType.EXECUTE
		b.block_format = "Change player %s score by {score: INT}" % player
		b.statement = "score_%s += {score}" % _POSITIONS_FOR_PLAYER[player]
		b.category = "Info | Score"
		block_list.append(b)

	return block_list
