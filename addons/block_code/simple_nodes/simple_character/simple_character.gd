@tool
class_name SimpleCharacter
extends CharacterBody2D

var sprite_texture: Texture2D = preload("res://icon.svg")


func _ready():
	$Sprite2D.texture = sprite_texture


func get_exposed_properties() -> Array[String]:
	return ["position"]


static func get_custom_blocks() -> Array[BlockCategory]:
	var b: Block

	# Input
	var input_list: Array[Block] = []
	b = CategoryFactory.BLOCKS["parameter_block"].instantiate()
	b.block_type = Types.BlockType.VECTOR2
	b.block_format = "Get WASD Input Vector"
	b.statement = 'Input.get_vector("Left", "Right", "Up", "Down")'
	input_list.append(b)

	# Movement
	var movement_list: Array[Block] = []
	b = CategoryFactory.BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Add movement input {input: VECTOR2} with speed {speed: INT}"
	b.statement = "velocity = {input}*{speed}\nmove_and_slide()"
	movement_list.append(b)

	var input_cat: BlockCategory = BlockCategory.new("Input", input_list, Color("5a5e72"))
	var movement_cat: BlockCategory = BlockCategory.new("Movement", movement_list, Color("4a86d5"))

	return [input_cat, movement_cat]

# Make sure this script is detached from the scene so that user can extend it!
