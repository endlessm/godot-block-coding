@tool
class_name SimpleCharacter
extends CharacterBody2D

@export var texture: Texture2D:
	set = _set_texture


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


static func get_custom_blocks() -> Array[Block]:
	var b: Block
	var block_list: Array[Block] = []

	# Movement
	b = CategoryFactory.BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Move with player 1 buttons, speed {speed: VECTOR2}"
	b.statement = (
		"var dir = Vector2()\n"
		+ "dir.x += float(Input.is_physical_key_pressed(KEY_D))\n"
		+ "dir.x -= float(Input.is_physical_key_pressed(KEY_A))\n"
		+ "dir.y += float(Input.is_physical_key_pressed(KEY_S))\n"
		+ "dir.y -= float(Input.is_physical_key_pressed(KEY_W))\n"
		+ "dir = dir.normalized()\n"
		+ "velocity = dir*{speed}\n"
		+ "move_and_slide()"
	)
	b.category = "Input"
	block_list.append(b)

	b = CategoryFactory.BLOCKS["statement_block"].instantiate()
	b.block_type = Types.BlockType.EXECUTE
	b.block_format = "Move with player 2 buttons, speed {speed: VECTOR2}"
	b.statement = (
		"var dir = Vector2()\n"
		+ "dir.x += float(Input.is_physical_key_pressed(KEY_RIGHT))\n"
		+ "dir.x -= float(Input.is_physical_key_pressed(KEY_LEFT))\n"
		+ "dir.y += float(Input.is_physical_key_pressed(KEY_DOWN))\n"
		+ "dir.y -= float(Input.is_physical_key_pressed(KEY_UP))\n"
		+ "dir = dir.normalized()\n"
		+ "velocity = dir*{speed}\n"
		+ "move_and_slide()"
	)
	b.category = "Input"
	block_list.append(b)

	return block_list
