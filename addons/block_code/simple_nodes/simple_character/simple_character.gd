@tool
class_name SimpleCharacter
extends CharacterBody2D

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")
const OptionData = preload("res://addons/block_code/code_generation/option_data.gd")
const Types = preload("res://addons/block_code/types/types.gd")

## A texture can be provided for simple setup. If provided, the character will have a collision box
## that matches the size of the texture.
@export var texture: Texture2D:
	set = _set_texture

@export var speed: Vector2 = Vector2(300, 300)

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

var sprite: Sprite2D
var collision: CollisionShape2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var _jumping = false
var direction_x: int = 0


func _set_texture(new_texture):
	texture = new_texture
	if is_node_ready():
		_texture_updated()


func _texture_updated():
	if not texture:
		if sprite:
			sprite.queue_free()
			sprite = null
		if collision:
			collision.queue_free()
			collision = null
		return

	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = &"Sprite2D"
		add_child(sprite)

	if not collision:
		collision = CollisionShape2D.new()
		collision.name = &"CollisionShape2D"
		collision.shape = RectangleShape2D.new()
		add_child(collision)

	sprite.texture = texture
	collision.shape.size = texture.get_size()


## Nodes in the "affected_by_gravity" group will receive gravity changes:
func on_gravity_changed(new_gravity):
	gravity = new_gravity


func _ready():
	simple_setup()


func simple_setup():
	add_to_group("affected_by_gravity", true)
	_texture_updated()


func get_custom_class():
	return "SimpleCharacter"


func _player_input_to_direction(player: String):
	var direction = Vector2()

	# Keyboard input (existing)
	direction.x += float(Input.is_physical_key_pressed(PLAYER_KEYS[player]["right"]))
	direction.x -= float(Input.is_physical_key_pressed(PLAYER_KEYS[player]["left"]))
	direction.y += float(Input.is_physical_key_pressed(PLAYER_KEYS[player]["down"]))
	direction.y -= float(Input.is_physical_key_pressed(PLAYER_KEYS[player]["up"]))

	# Gamepad input (new)
	if player == "player_1" or player == "player_2":
		var joy_index = 0 if player == "player_1" else 1  # Assuming player 1 uses the first gamepad and player 2 uses the second
		# Horizontal movement (left stick x-axis)
		direction.x += Input.get_joy_axis(joy_index, JOY_AXIS_0)  # Left stick X-axis
		# Vertical movement (left stick y-axis)
		direction.y += Input.get_joy_axis(joy_index, JOY_AXIS_1)  # Left stick Y-axis

		# You can also check for specific gamepad button presses if needed
		# For example, A button for jumping (Button 0) on player 1 and player 2
		if Input.is_joy_button_pressed(joy_index, JOY_BUTTON_0):  # Button 0 (A button on most controllers)
			# Handle button press (for jumping or other actions)
			pass

	return direction


func move_with_player_buttons(player: String, kind: String, delta: float, input_type: String):
	var direction = Vector2()

	# Handle input based on the selected input type (keyboard or gamepad)
	if input_type == "keyboard":
		# Get direction using keyboard input (existing)
		direction = _player_input_to_direction(player)
	elif input_type == "gamepad":
		# Get direction using gamepad input (newly added)
		direction = _player_input_to_direction(player)  # This function now also supports gamepad

	direction_x = direction.x

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


static func setup_custom_blocks():
	var _class_name = "SimpleCharacter"
	var block_list: Array[BlockDefinition] = []

	# Movement block definition
	var block_definition: BlockDefinition = BlockDefinition.new()
	block_definition.name = &"simplecharacter_move"
	block_definition.target_node_class = _class_name
	block_definition.category = "Input"
	block_definition.type = Types.BlockType.STATEMENT
	block_definition.display_template = "move with {player: NIL} buttons as {kind: NIL} using {input_type: NIL}"
	block_definition.description = """Move the character using the configured controls. You can select between keyboard or gamepad for the input.

	“Top-down” enables the character to move in both x (horizontal) and y (vertical) dimensions, like a top-down view.

	“Platformer” enables the character to move as in a side-scroller, with gravity affecting vertical movement.

	“Spaceship” uses the left/right controls to rotate and up/down controls to move forward or backward."""

	# Updated code template to include input type
	block_definition.code_template = "move_with_player_buttons({player}, {kind}, delta, {input_type})"

	# Add new input type option (keyboard or gamepad)
	block_definition.defaults = {
		"player": OptionData.new(["player_1", "player_2"]), "kind": OptionData.new(["top-down", "platformer", "spaceship"]), "input_type": OptionData.new(["keyboard", "gamepad"])  # Add gamepad option
	}

	# Add block definition to the block list
	block_list.append(block_definition)

	# Define custom properties
	var property_list: Array[Dictionary] = [
		{
			"name": "speed",
			"type": TYPE_VECTOR2,
		},
		{
			"name": "direction_x",
			"type": TYPE_INT,
		},
	]

	var property_settings = {
		"speed":
		{
			"category": "Physics | Velocity",
		},
		"direction_x":
		{
			"category": "Physics | Velocity",
			"has_setter": false,
		},
	}

	BlocksCatalog.add_custom_blocks(_class_name, block_list, property_list, property_settings)
