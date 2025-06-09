@tool
class_name SimpleEnding
extends Label

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")
const OptionData = preload("res://addons/block_code/code_generation/option_data.gd")
const Types = preload("res://addons/block_code/types/types.gd")

## The message that will be shown when the player wins the game.
@export var win_message: String = "YOU WIN!"

## The message that will be shown when the player loses the game.
@export var lose_message: String = "GAME OVER"


func game_over(result: String):
	match result:
		"WIN":
			text = win_message
		"LOSE":
			text = lose_message
		_:
			reset()
			push_warning('Unrecognized game result "%s"' % result)


func reset():
	# Workaround for POT generation extracting empty string.
	text = str("")


func _ready():
	simple_setup()


func simple_setup():
	if not label_settings:
		label_settings = LabelSettings.new()
		label_settings.font_size = 200
	horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER


func _enter_tree():
	# In the editor, show the win message so that adjusting the label
	# properties is visible. Otherwise, clear the text when entering the tree
	# so that the label text persisted in the scene file isn't shown.
	#
	# Normally this would be done in _ready, but a block script might override
	# that and simple_setup is too late.
	if Engine.is_editor_hint():
		text = win_message
	else:
		reset()


func get_custom_class():
	return "SimpleEnding"


static func setup_custom_blocks():
	var _class_name = "SimpleEnding"
	var block_list: Array[BlockDefinition] = []
	var block_definition: BlockDefinition

	block_definition = BlockDefinition.new()
	block_definition.name = &"simpleending_game_over"
	block_definition.target_node_class = _class_name
	block_definition.category = "Lifecycle | Game"
	block_definition.type = Types.BlockType.STATEMENT
	block_definition.display_template = Engine.tr("game over {result: STRING}")
	block_definition.code_template = "game_over({result})"
	block_definition.defaults = {
		"result": OptionData.new(["WIN", "LOSE"]),
	}
	block_definition.description = Engine.tr("Show the game over label with the win or lose message.")
	block_list.append(block_definition)

	block_definition = BlockDefinition.new()
	block_definition.name = &"simpleending_reset"
	block_definition.target_node_class = _class_name
	block_definition.category = "Lifecycle | Game"
	block_definition.type = Types.BlockType.STATEMENT
	block_definition.display_template = Engine.tr("reset game over")
	block_definition.code_template = "reset()"
	block_definition.description = Engine.tr("Reset the game over label.")
	block_list.append(block_definition)

	BlocksCatalog.add_custom_blocks(_class_name, block_list)
