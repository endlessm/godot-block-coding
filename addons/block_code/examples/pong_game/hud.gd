extends CanvasLayer

@onready var _score_labels = {
	"left": %PlayerLeftScore,
	"right": %PlayerRightScore,
}


## Sets the score for one player.
func set_player_score(player: String, score: int):
	var text = _score_labels[player].text
	if str(score) != text:
		_score_labels[player].text = str(score)


## Sets the score for each player.
func set_players_scores(left_score: int, right_score: int):
	set_player_score("left", left_score)
	set_player_score("right", right_score)
