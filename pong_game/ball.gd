@tool
class_name Ball
extends RigidBody2D

const _INITIAL_RADIUS: int = 64

## This is how fast your ball moves.
@export_range(0.0, 10000.0, 0.5, "suffix:px/s") var initial_speed: float = 500.0

## This is the initial angle of the ball.
@export_range(-180, 180, 0.5, "radians_as_degrees") var initial_direction: float = PI / 4

## How big is this ball?
@export_range(0.1, 5.0, 0.1) var size: float = 1.0:
	set = _set_size

@onready var _shape: CollisionShape2D = %CollisionShape2D
@onready var _sprite: Sprite2D = %Sprite2D


func _set_size(new_size: float):
	size = new_size
	if not is_node_ready():
		await ready
	_shape.shape.radius = _INITIAL_RADIUS * size
	_sprite.scale = Vector2(size, size)


func _ready():
	if Engine.is_editor_hint():
		set_process(false)
		set_physics_process(false)
	reset()


func reset():
	linear_velocity = Vector2.from_angle(initial_direction) * initial_speed
	angular_velocity = 0.0
	_set_size(size)
