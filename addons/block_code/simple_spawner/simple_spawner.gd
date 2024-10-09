@tool
class_name SimpleSpawner
extends Node2D

const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")
const BlocksCatalog = preload("res://addons/block_code/code_generation/blocks_catalog.gd")
const OptionData = preload("res://addons/block_code/code_generation/option_data.gd")
const Types = preload("res://addons/block_code/types/types.gd")

enum SpawnParent {
	THIS,  ## Spawned scenes are children of this node
	SCENE,  ## Spawned scenes are children of the scene
}
enum LimitBehavior { REPLACE, NO_SPAWN }

## The scenes to spawn. If more than one are provided, they will be picked randomly.
@export var scenes: Array[PackedScene] = []

## The node that the spawned scenes should be a child of. If you want to move
## the SimpleSpawner without moving the scenes it has already spawned, choose
## SCENE.
@export var spawn_parent: SpawnParent

## The period of time in seconds to spawn another component. If zero, they won't spawn
## automatically. Use the "Spawn" block.
@export_range(0.0, 10.0, 0.1, "or_greater") var spawn_frequency: float = 0.0:
	set = _set_spawn_fraquency

## How many spawned scenes are allowed. If zero, there is no limit.
@export_range(0, 50, 0.1, "or_greater") var spawn_limit: int = 50

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


func _set_spawn_fraquency(new_frequency: float):
	spawn_frequency = new_frequency
	if not _timer or not is_instance_valid(_timer):
		return
	_timer.wait_time = spawn_frequency


func spawn_start():
	if spawn_frequency == 0.0:
		return
	if not _timer or not is_instance_valid(_timer):
		_timer = Timer.new()
		add_child(_timer)
		_timer.wait_time = spawn_frequency
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

	_spawned_scenes = _spawned_scenes.filter(func(instance): return is_instance_valid(instance))

	if spawn_limit != 0 and _spawned_scenes.size() >= spawn_limit:
		if limit_behavior == LimitBehavior.NO_SPAWN:
			return
		else:
			_remove_oldest_spawned()

	var scene: PackedScene = scenes.pick_random()
	var spawned = scene.instantiate()
	_spawned_scenes.push_back(spawned)
	match spawn_parent:
		SpawnParent.THIS:
			add_child(spawned)
		SpawnParent.SCENE:
			get_tree().current_scene.add_child(spawned)
			spawned.position = global_position


func do_set_spawn_frequency(new_frequency: float):
	_set_spawn_fraquency(new_frequency)


static func setup_custom_blocks():
	var _class_name = "SimpleSpawner"
	var block_list: Array[BlockDefinition] = []

	var block_definition: BlockDefinition = BlockDefinition.new()
	block_definition.name = &"simplespawner_spawn_once"
	block_definition.target_node_class = _class_name
	block_definition.category = "Lifecycle | Spawn"
	block_definition.type = Types.BlockType.STATEMENT
	block_definition.display_template = "spawn once"
	block_definition.code_template = "spawn_once()"
	block_list.append(block_definition)

	block_definition = BlockDefinition.new()
	block_definition.name = &"simplespawner_start_spawning"
	block_definition.target_node_class = _class_name
	block_definition.category = "Lifecycle | Spawn"
	block_definition.type = Types.BlockType.STATEMENT
	block_definition.display_template = "start spawning"
	block_definition.code_template = "spawn_start()"
	block_list.append(block_definition)

	block_definition = BlockDefinition.new()
	block_definition.name = &"simplespawner_stop_spawning"
	block_definition.target_node_class = _class_name
	block_definition.category = "Lifecycle | Spawn"
	block_definition.type = Types.BlockType.STATEMENT
	block_definition.display_template = "stop spawning"
	block_definition.code_template = "spawn_stop()"
	block_list.append(block_definition)

	block_definition = BlockDefinition.new()
	block_definition.name = &"simplespawner_is_spawning"
	block_definition.target_node_class = _class_name
	block_definition.category = "Lifecycle | Spawn"
	block_definition.type = Types.BlockType.VALUE
	block_definition.variant_type = TYPE_BOOL
	block_definition.display_template = "is spawning"
	block_definition.code_template = "is_spawning()"
	block_list.append(block_definition)

	block_definition = BlockDefinition.new()
	block_definition.name = &"simplespawner_set_spawn_frequency"
	block_definition.target_node_class = _class_name
	block_definition.category = "Lifecycle | Spawn"
	block_definition.type = Types.BlockType.STATEMENT
	block_definition.display_template = "set spawn frequency to {new_frequency: FLOAT}"
	block_definition.code_template = "do_set_spawn_frequency({new_frequency})"
	block_list.append(block_definition)

	block_definition = BlockDefinition.new()
	block_definition.name = &"simplespawner_get_spawn_frequency"
	block_definition.target_node_class = _class_name
	block_definition.category = "Lifecycle | Spawn"
	block_definition.type = Types.BlockType.VALUE
	block_definition.variant_type = TYPE_FLOAT
	block_definition.display_template = "spawn frequency"
	block_definition.code_template = "spawn_frequency"
	block_list.append(block_definition)

	BlocksCatalog.add_custom_blocks(_class_name, block_list, [], {})
