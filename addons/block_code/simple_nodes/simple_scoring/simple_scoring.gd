@tool
class_name SimpleScoring
extends CanvasLayer

const CategoryFactory = preload("res://addons/block_code/ui/picker/categories/category_factory.gd")
const Types = preload("res://addons/block_code/types/types.gd")
const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")

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


func _init():
	if self.get_parent():
		return

	var node = preload("res://addons/block_code/simple_nodes/simple_scoring/_simple_scoring.tscn").instantiate() as Node
	node.replace_by(self, true)
	node.queue_free()
	scene_file_path = ""


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


static func get_custom_blocks() -> Array[BlockDefinition]:
	var bd: BlockDefinition
	var block_definition_list: Array[BlockDefinition] = []

	for player in _POSITIONS_FOR_PLAYER:
		bd = BlockDefinition.new()
		bd.name = "simplescoring_set_score_%s" % player
		bd.category = "Info | Score"
		bd.type = Types.BlockType.STATEMENT
		bd.display_template = "Set player %s score to {score: INT}" % player
		bd.code_template = "score_%s = {score}" % _POSITIONS_FOR_PLAYER[player]
		block_definition_list.append(bd)

		bd = BlockDefinition.new()
		bd.name = "simplescoring_change_score_%s" % player
		bd.category = "Info | Score"
		bd.type = Types.BlockType.STATEMENT
		bd.display_template = "Change player %s score by {score: INT}" % player
		bd.code_template = "score_%s += {score}" % _POSITIONS_FOR_PLAYER[player]
		block_definition_list.append(bd)

	return block_definition_list
