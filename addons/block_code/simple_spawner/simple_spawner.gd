@tool
class_name SimpleSpawner
extends Node2D
## SimpleSpawner node.
##
## If multiple spawned scenes are provided, one is picked ramdomly when spawning.
##
## Spawned instances are children of the current scene.
##
## The scene being spawned is rotated according to this node's global rotation:
## - If the spawned scene is a RigidBody2D, the linear velocity and constant forces
##   are rotated according to the SimpleSpawner node global rotation.
## - If the spawned scene is a Node2D, the rotation is copied from the SimpleSpawner node.

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")
const OptionData = preload("res://addons/block_code/code_generation/option_data.gd")
const Types = preload("res://addons/block_code/types/types.gd")

enum LimitBehavior { REPLACE, NO_SPAWN }

## The scenes to spawn. If more than one are provided, they will be picked randomly.
@export var scenes: Array[PackedScene] = []

## The period of time in seconds to spawn another component. If zero, they won't spawn
## automatically. Use the "Spawn" block.
@export_range(0.0, 10.0, 0.1, "or_greater", "suffix:s") var spawn_period: float = 0.0:
	set = _set_spawn_period

## How many spawned scenes are allowed. If zero, there is no limit.
@export_range(0, 50, 0.1, "or_greater", "suffix:scenes") var spawn_limit: int = 50

## What happens when the limit is reached and a new spawn is attempted:
## - Replace: Remove the oldest spawned scene and spawn a new one.
## - No Spawn: No spawn happens until any spawned scene is removed by other means.
@export var limit_behavior: LimitBehavior

var _timer: Timer
var _spawned_scenes: Array[Node]


func _ready() -> void:
	set_process(false)
	set_physics_process(false)


func get_custom_class():
	return "SimpleSpawner"


func _remove_oldest_spawned():
	var spawned = _spawned_scenes.pop_front()
	if is_instance_valid(spawned):
		spawned.get_parent().remove_child(spawned)


func _set_spawn_period(new_period: float):
	spawn_period = new_period
	if not _timer or not is_instance_valid(_timer):
		return
	_timer.wait_time = spawn_period


func spawn_start():
	if spawn_period == 0.0:
		return
	if not _timer or not is_instance_valid(_timer):
		_timer = Timer.new()
		add_child(_timer)
		_timer.wait_time = spawn_period
		_timer.timeout.connect(spawn_once)
	_timer.start()
	spawn_once.call_deferred()


func spawn_stop():
	if not _timer or not is_instance_valid(_timer):
		return
	_timer.stop()


func is_spawning():
	if not _timer or not is_instance_valid(_timer):
		return false
	return not _timer.is_stopped()


func spawn_once():
	if scenes.size() == 0:
		return

	_spawned_scenes = _spawned_scenes.filter(is_instance_valid)

	if spawn_limit != 0 and _spawned_scenes.size() >= spawn_limit:
		if limit_behavior == LimitBehavior.NO_SPAWN:
			return
		else:
			_remove_oldest_spawned()

	var scene: PackedScene = scenes.pick_random()
	var spawned = scene.instantiate()
	_spawned_scenes.push_back(spawned)
	# Rotate the spawned scene according to the SimpleSpawner:
	if spawned is RigidBody2D:
		spawned.linear_velocity = spawned.linear_velocity.rotated(global_rotation)
		spawned.constant_force = spawned.constant_force.rotated(global_rotation)
	elif spawned is Node2D:
		spawned.rotate(global_rotation)
	# Add the spawned instance to the current scene:
	get_tree().current_scene.add_child(spawned)
	spawned.position = global_position


static func setup_custom_blocks():
	var _class_name = "SimpleSpawner"
	var block_list: Array[BlockDefinition] = []

	var block_definition: BlockDefinition = BlockDefinition.new()
	block_definition.name = &"simplespawner_spawn_once"
	block_definition.target_node_class = _class_name
	block_definition.category = "Lifecycle | Spawn"
	block_definition.type = Types.BlockType.STATEMENT
	block_definition.display_template = Engine.tr("spawn once")
	block_definition.code_template = "spawn_once()"
	block_list.append(block_definition)

	block_definition = BlockDefinition.new()
	block_definition.name = &"simplespawner_start_spawning"
	block_definition.target_node_class = _class_name
	block_definition.category = "Lifecycle | Spawn"
	block_definition.type = Types.BlockType.STATEMENT
	block_definition.display_template = Engine.tr("start spawning")
	block_definition.code_template = "spawn_start()"
	block_list.append(block_definition)

	block_definition = BlockDefinition.new()
	block_definition.name = &"simplespawner_stop_spawning"
	block_definition.target_node_class = _class_name
	block_definition.category = "Lifecycle | Spawn"
	block_definition.type = Types.BlockType.STATEMENT
	block_definition.display_template = Engine.tr("stop spawning")
	block_definition.code_template = "spawn_stop()"
	block_list.append(block_definition)

	block_definition = BlockDefinition.new()
	block_definition.name = &"simplespawner_is_spawning"
	block_definition.target_node_class = _class_name
	block_definition.category = "Lifecycle | Spawn"
	block_definition.type = Types.BlockType.VALUE
	block_definition.variant_type = TYPE_BOOL
	block_definition.display_template = Engine.tr("is spawning")
	block_definition.code_template = "is_spawning()"
	block_list.append(block_definition)

	block_definition = BlockDefinition.new()
	block_definition.name = &"simplespawner_set_spawn_period"
	block_definition.target_node_class = _class_name
	block_definition.category = "Lifecycle | Spawn"
	block_definition.type = Types.BlockType.STATEMENT
	block_definition.display_template = Engine.tr("set spawn period to {new_period: FLOAT}")
	block_definition.code_template = "spawn_period = {new_period}"
	block_list.append(block_definition)

	block_definition = BlockDefinition.new()
	block_definition.name = &"simplespawner_get_spawn_period"
	block_definition.target_node_class = _class_name
	block_definition.category = "Lifecycle | Spawn"
	block_definition.type = Types.BlockType.VALUE
	block_definition.variant_type = TYPE_FLOAT
	block_definition.display_template = Engine.tr("spawn period")
	block_definition.code_template = "spawn_period"
	block_list.append(block_definition)

	BlocksCatalog.add_custom_blocks(_class_name, block_list, [], {})


# Backwards compatibility handling
func _get_property_list() -> Array[Dictionary]:
	return [
		{
			# spawn_frequency was renamed to spawn_period
			"name": "spawn_frequency",
			"class_name": &"",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
			"usage": PROPERTY_USAGE_NONE,
		},
	]


func _get(property: StringName) -> Variant:
	match property:
		"spawn_frequency":
			return spawn_period
		_:
			return null


func _set(property: StringName, value: Variant) -> bool:
	match property:
		"spawn_frequency":
			print("Migrating SimpleSpawner spawn_frequency property to new name spawn_period")
			spawn_period = value
		_:
			return false

	# Any migrated properties need to be resaved.
	if Engine.is_editor_hint():
		EditorInterface.mark_scene_as_unsaved()
	return true
