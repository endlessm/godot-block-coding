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

const PLAYER_KEYS = [
	{
		"up": KEY_W,
		"down": KEY_S,
		"left": KEY_A,
		"right": KEY_D,
	},
	{
		"up": KEY_UP,
		"down": KEY_DOWN,
		"left": KEY_LEFT,
		"right": KEY_RIGHT,
	}
]

const PLAYER_JOYSTICK_BUTTONS = {
	"up": JOY_BUTTON_DPAD_UP,
	"down": JOY_BUTTON_DPAD_DOWN,
	"left": JOY_BUTTON_DPAD_LEFT,
	"right": JOY_BUTTON_DPAD_RIGHT,
}

const PLAYER_JOYSTICK_MOTION = {
	"up":
	{
		"axis": JOY_AXIS_LEFT_Y,
		"axis_value": -1,
	},
	"down":
	{
		"axis": JOY_AXIS_LEFT_Y,
		"axis_value": 1,
	},
	"left":
	{
		"axis": JOY_AXIS_LEFT_X,
		"axis_value": -1,
	},
	"right":
	{
		"axis": JOY_AXIS_LEFT_X,
		"axis_value": 1,
	},
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
	_setup_actions()
	_texture_updated()


func _setup_actions():
	if Engine.is_editor_hint() or InputMap.has_action("player_1_left"):
		return

	for i in PLAYER_KEYS.size():
		for action in PLAYER_KEYS[i]:
			var player = "player_%d" % [i + 1]
			var action_name = player + "_" + action
			InputMap.add_action(action_name)

			#keyboard event
			var e = InputEventKey.new()
			e.physical_keycode = PLAYER_KEYS[i][action]
			InputMap.action_add_event(action_name, e)

			#controller d-pad event
			var ej = InputEventJoypadButton.new()
			ej.device = i
			ej.button_index = PLAYER_JOYSTICK_BUTTONS[action]
			InputMap.action_add_event(action_name, ej)

			#controller left stick event
			var ejm = InputEventJoypadMotion.new()
			ejm.device = i
			ejm.axis = PLAYER_JOYSTICK_MOTION[action]["axis"]
			ejm.axis_value = PLAYER_JOYSTICK_MOTION[action]["axis_value"]
			InputMap.action_add_event(action_name, ejm)


func get_custom_class():
	return "SimpleCharacter"


func move_with_player_buttons(player: String, kind: String, delta: float):
	var direction = Input.get_vector(player + "_left", player + "_right", player + "_up", player + "_down")
	direction_x = direction.x

	if kind == "top-down":
		velocity = direction * speed

	elif kind == "platformer":
		velocity.x = direction.x * speed.x
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			if not _jumping and direction.y < 0:
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

	# Movement
	var block_definition: BlockDefinition = BlockDefinition.new()
	block_definition.name = &"simplecharacter_move"
	block_definition.target_node_class = _class_name
	block_definition.category = "Input"
	block_definition.type = Types.BlockType.STATEMENT
	block_definition.display_template = Engine.tr("move with {player: NIL} buttons as {kind: NIL}")
	block_definition.description = (
		Engine
		. tr(
			"""Move the character using the “Player 1” or “Player 2” controls as configured in Godot.

“Top-down” enables the character to move in both x (horizontal) and y (vertical) dimensions, as if the camera is above the character, looking down. No gravity is added.

“Platformer” enables the character to move as if the camera is looking from the side, like a side-scroller. Gravity is applied on the y (vertical) axis, making the character fall down until they collide with something.

“Spaceship” uses the left/right controls to rotate the character and up/down controls to go forward or backward in the direction they are pointing."""
		)
	)
	# TODO: delta here is assumed to be the parameter name of
	# the _process or _physics_process method:
	block_definition.code_template = "move_with_player_buttons({player}, {kind}, delta)"
	block_definition.defaults = {
		"player": OptionData.new(["player_1", "player_2"]),
		"kind": OptionData.new(["top-down", "platformer", "spaceship"]),
	}
	block_list.append(block_definition)

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
