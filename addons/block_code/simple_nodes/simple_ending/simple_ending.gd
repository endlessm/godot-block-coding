@tool
class_name SimpleEnding
extends Control

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")
const OptionData = preload("res://addons/block_code/code_generation/option_data.gd")
const Types = preload("res://addons/block_code/types/types.gd")

## Emitted when SimpleEnding has completed setup.
signal setup

## The message that will be shown when the player wins the game.
@export var win_message: String = "YOU WIN!"

## The message that will be shown when the player loses the game.
@export var lose_message: String = "GAME OVER"

## Text settings for the message label.
@export var label_settings: LabelSettings

var _label: Label


func game_over(result: String):
	# Wait until simple_setup completes so the label exists.
	await setup

	match result:
		"WIN":
			_label.text = win_message
		"LOSE":
			_label.text = lose_message
		_:
			_label.text = ""
			push_warning('Unrecognized game result "%s"' % result)


func reset():
	# Wait until simple_setup completes so the label exists.
	await setup

	_label.text = ""


func _create_label_settings():
	if label_settings:
		return

	label_settings = LabelSettings.new()
	label_settings.font_size = 200


func _create_label():
	if _label:
		return

	_label = Label.new()
	_label.label_settings = label_settings
	_label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER

	add_child(_label)


func _ready():
	simple_setup()


func simple_setup():
	_create_label_settings()
	_create_label()

	if Engine.is_editor_hint():
		# Show the win message in the editor so adjusting the label settings
		# is visible.
		_label.text = win_message

	setup.emit()


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
	block_definition.display_template = "game over {result: STRING}"
	block_definition.code_template = "game_over({result})"
	block_definition.defaults = {
		"result": OptionData.new(["WIN", "LOSE"]),
	}
	block_definition.description = "Show the game over label with the win or lose message."
	block_list.append(block_definition)

	block_definition = BlockDefinition.new()
	block_definition.name = &"simpleending_reset"
	block_definition.target_node_class = _class_name
	block_definition.category = "Lifecycle | Game"
	block_definition.type = Types.BlockType.STATEMENT
	block_definition.display_template = "reset game over"
	block_definition.code_template = "reset()"
	block_definition.description = "Reset the game over label."
	block_list.append(block_definition)

	BlocksCatalog.add_custom_blocks(_class_name, block_list)
