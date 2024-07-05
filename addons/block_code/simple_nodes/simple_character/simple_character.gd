@tool
class_name SimpleCharacter
extends CharacterBody2D

@export var texture: Texture2D:
	set = _set_texture

const PLAYER_KEYS = {
	"player_1":
	{
		"up": KEY_W,
		"down": KEY_S,
		"left": KEY_A,
		"right": KEY_D,
	},
	"player_2":
	{
		"up": KEY_UP,
		"down": KEY_DOWN,
		"left": KEY_LEFT,
		"right": KEY_RIGHT,
	}
}


func _set_texture(new_texture):
	texture = new_texture

	if not is_node_ready():
		return

	$Sprite2D.texture = texture
	var shape = RectangleShape2D.new()
	shape.size = Vector2(100, 100) if texture == null else texture.get_size()
	$CollisionShape2D.shape = shape


func _ready():
	simple_setup()


func simple_setup():
	_set_texture(texture)


func get_custom_class():
	return "SimpleCharacter"


func move_with_player_buttons(player: String, speed: Vector2):
	var dir = Vector2()
	dir.x += float(Input.is_physical_key_pressed(PLAYER_KEYS[player]["right"]))
	dir.x -= float(Input.is_physical_key_pressed(PLAYER_KEYS[player]["left"]))
	dir.y += float(Input.is_physical_key_pressed(PLAYER_KEYS[player]["down"]))
	dir.y -= float(Input.is_physical_key_pressed(PLAYER_KEYS[player]["up"]))
	velocity = dir.normalized() * speed
	move_and_slide()


static func get_custom_blocks() -> Array[Block]:
	var b: Block
	var block_list: Array[Block] = []

	# Movement
	b = CategoryFactory.BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Move with player 1 buttons, speed {speed: VECTOR2}"
	b.statement = "move_with_player_buttons('player_1', {speed})"
	b.category = "Input"
	block_list.append(b)

	b = CategoryFactory.BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Move with player 2 buttons, speed {speed: VECTOR2}"
	b.statement = "move_with_player_buttons('player_2', {speed})"
	b.category = "Input"
	block_list.append(b)

	return block_list
