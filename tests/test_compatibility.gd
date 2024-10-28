extends GutTest
## Tests for scene file backwards compatibility


func get_scene_state_node_index(state: SceneState, name: String) -> int:
	for idx in state.get_node_count():
		if state.get_node_name(idx) == name:
			return idx
	return -1


func get_scene_state_node_prop_index(state: SceneState, node_idx: int, name: String) -> int:
	for prop_idx in state.get_node_property_count(node_idx):
		if state.get_node_property_name(node_idx, prop_idx) == name:
			return prop_idx
	return -1


func _get_block_names_recursive(block: Resource, names: Array[String]):
	names.append(block.name)
	if "children" in block:
		for child in block.children:
			_get_block_names_recursive(child, names)
	for value in block.arguments.values():
		if not value is Resource:
			continue
		if not value.script:
			continue
		if value.script.resource_path != "res://addons/block_code/serialization/value_block_serialization.gd":
			continue
		_get_block_names_recursive(value, names)


func get_block_script_block_names(block_script: Resource) -> Array[String]:
	var names: Array[String]
	for tree in block_script.block_serialization_trees:
		_get_block_names_recursive(tree.root, names)
	return names


func _get_block_argument_names_recursive(block: Resource, names: Array[String]):
	names.append_array(block.arguments.keys())
	if "children" in block:
		for child in block.children:
			_get_block_argument_names_recursive(child, names)
	for value in block.arguments.values():
		if not value is Resource:
			continue
		if not value.script:
			continue
		if value.script.resource_path != "res://addons/block_code/serialization/value_block_serialization.gd":
			continue
		_get_block_argument_names_recursive(value, names)


func get_block_script_argument_names(block_script: Resource) -> Array[String]:
	var names: Array[String]
	for tree in block_script.block_serialization_trees:
		_get_block_argument_names_recursive(tree.root, names)
	return names


func test_simple_spawner():
	const old_block_names: Array[String] = [
		"simplespawner_get_spawn_frequency",
		"simplespawner_set_spawn_frequency",
	]

	const new_block_names: Array[String] = [
		"simplespawner_get_spawn_period",
		"simplespawner_set_spawn_period",
	]

	const old_argument_names: Array[String] = [
		"new_frequency",
	]

	const new_argument_names: Array[String] = [
		"new_period",
	]

	var scene: PackedScene = load("res://tests/data/simple_spawner_compat.tscn")
	assert_not_null(scene)
	assert_true(scene.can_instantiate(), "Scene should be instantiable")

	var scene_state := scene.get_state()
	var spawner_idx := get_scene_state_node_index(scene_state, "SimpleSpawner")
	assert_gt(spawner_idx, -1, "SimpleSpawner node could not be found")

	# The packed SimpleSpawner node should have a simple_frequency
	# property but no simple_period property.
	var frequency_idx := get_scene_state_node_prop_index(scene_state, spawner_idx, "spawn_frequency")
	var period_idx := get_scene_state_node_prop_index(scene_state, spawner_idx, "spawn_period")
	assert_gt(frequency_idx, -1, "Old SimpleSpawner node should have spawn_frequency property")
	assert_lt(period_idx, 0, "Old SimpleSpawner node should not have spawn_period property")

	var packed_frequency = scene_state.get_node_property_value(spawner_idx, frequency_idx)
	assert_typeof(packed_frequency, TYPE_FLOAT)
	assert_eq(packed_frequency, 5.0)

	var block_code_idx := get_scene_state_node_index(scene_state, "BlockCode")
	assert_gt(block_code_idx, -1, "BlockCode node could not be found")
	var block_script_idx := get_scene_state_node_prop_index(scene_state, block_code_idx, "block_script")
	assert_gt(block_script_idx, -1, "BlockCode node block_script could not be found")
	var packed_block_script = scene_state.get_node_property_value(block_code_idx, block_script_idx)
	assert_typeof(packed_block_script, TYPE_OBJECT)
	assert_eq("Resource", packed_block_script.get_class())
	assert_eq(packed_block_script.script.resource_path, "res://addons/block_code/serialization/block_script_serialization.gd")

	# Unlike Nodes, Resources are created immediately when loading the
	# scene, so the block names and arguments should already be migrated.
	var packed_block_names := get_block_script_block_names(packed_block_script)
	for name in old_block_names:
		assert_does_not_have(packed_block_names, name, "Block script should not have old name %s" % name)
	for name in new_block_names:
		assert_has(packed_block_names, name, "Block script should have new name %s" % name)

	var packed_argument_names := get_block_script_argument_names(packed_block_script)
	for name in old_argument_names:
		assert_does_not_have(packed_argument_names, name, "Block script should not have old argument %s" % name)
	for name in new_argument_names:
		assert_has(packed_argument_names, name, "Block script should have new argument %s" % name)

	# Instantiate the scene and check the Node properties.
	var root := scene.instantiate()
	assert_not_null(root)
	autoqfree(root)

	var spawner: SimpleSpawner = root.get_node("SimpleSpawner")
	assert_eq(spawner.spawn_frequency, 5.0)
	assert_eq(spawner.spawn_period, 5.0)

	# Pack the scene and check that the old properties won't be saved.
	var err: Error = scene.pack(root)
	assert_eq(err, OK, "Packing scene should not cause an error")

	scene_state = scene.get_state()
	spawner_idx = get_scene_state_node_index(scene_state, "SimpleSpawner")
	assert_gt(spawner_idx, -1, "SimpleSpawner node could not be found")

	# The newly packed SimpleSpawner node should have a simple_period
	# property but no simple_frequency property.
	period_idx = get_scene_state_node_prop_index(scene_state, spawner_idx, "spawn_period")
	frequency_idx = get_scene_state_node_prop_index(scene_state, spawner_idx, "spawn_frequency")
	assert_gt(period_idx, -1, "New SimpleSpawner node should have spawn_period property")
	assert_lt(frequency_idx, 0, "New SimpleSpawner node should not have spawn_frequency property")

	var packed_period = scene_state.get_node_property_value(spawner_idx, period_idx)
	assert_typeof(packed_period, TYPE_FLOAT)
	assert_eq(packed_period, 5.0)
