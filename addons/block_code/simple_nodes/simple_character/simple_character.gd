@tool
class_name SimpleCharacter
extends CharacterBody2D

const CategoryFactory = preload("res://addons/block_code/ui/picker/categories/category_factory.gd")
const Types = preload("res://addons/block_code/types/types.gd")
const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")

@export var texture: Texture2D:
	set = _set_texture

@export var speed: Vector2 = Vector2(300, 300):
	set = _set_speed

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

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var _jumping = false


func _set_texture(new_texture):
	texture = new_texture

	if not is_node_ready():
		return

	$Sprite2D.texture = texture
	var shape = RectangleShape2D.new()
	shape.size = Vector2(100, 100) if texture == null else texture.get_size()
	$CollisionShape2D.shape = shape


func _set_speed(new_speed):
	speed = new_speed


## Nodes in the "affected_by_gravity" group will receive gravity changes:
func on_gravity_changed(new_gravity):
	gravity = new_gravity


func _init():
	if self.get_parent():
		return

	var node = preload("res://addons/block_code/simple_nodes/simple_character/_simple_character.tscn").instantiate() as Node
	node.replace_by(self, true)
	node.queue_free()
	scene_file_path = ""


func _ready():
	add_to_group("affected_by_gravity")
	simple_setup()


func simple_setup():
	_set_texture(texture)
	_set_speed(speed)


func get_custom_class():
	return "SimpleCharacter"


func _player_input_to_direction(player: String):
	var direction = Vector2()
	direction.x += float(Input.is_physical_key_pressed(PLAYER_KEYS[player]["right"]))
	direction.x -= float(Input.is_physical_key_pressed(PLAYER_KEYS[player]["left"]))
	direction.y += float(Input.is_physical_key_pressed(PLAYER_KEYS[player]["down"]))
	direction.y -= float(Input.is_physical_key_pressed(PLAYER_KEYS[player]["up"]))
	return direction


func move_with_player_buttons(player: String, kind: String, delta: float):
	var direction = _player_input_to_direction(player)

	if kind == "top-down":
		velocity = direction * speed

	elif kind == "platformer":
		velocity.x = direction.x * speed.x
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			if not _jumping and Input.is_physical_key_pressed(PLAYER_KEYS[player]["up"]):
				_jumping = true
				velocity.y -= speed.y
			else:
				_jumping = false

	elif kind == "spaceship":
		rotation_degrees += direction.x * speed.x / 100.0
		velocity = Vector2.DOWN.rotated(rotation) * speed.y * direction.y
	move_and_slide()


static func get_custom_blocks() -> Array[BlockDefinition]:
	var bd: BlockDefinition
	var block_definition_list: Array[BlockDefinition] = []

	# Movement
	bd = BlockDefinition.new()
	bd.name = "simplecharacter_move"
	bd.type = Types.BlockType.STATEMENT
	bd.category = "Input"
	bd.display_template = "Move with {player: OPTION} buttons as {kind: OPTION}"

	# TODO: delta here is assumed to be the parameter name of
	# the _process or _physics_process method:
	bd.code_template = 'move_with_player_buttons("{player}", "{kind}", delta)'
	bd.defaults = {
		"player": OptionData.new(["player_1", "player_2"]),
		"kind": OptionData.new(["top-down", "platformer", "spaceship"]),
	}
	block_definition_list.append(bd)

	var props = [
		{
			"name": "speed",
			"type": TYPE_VECTOR2,
			"category": "Physics | Velocity",
		}
	]
	for prop in props:
		var property_blocks = CategoryFactory.property_to_blocklist(prop)
		block_definition_list.append_array(property_blocks)

	return block_definition_list
