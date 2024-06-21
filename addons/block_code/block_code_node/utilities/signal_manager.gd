extends Node


func broadcast_signal(group: String, signal_name: String):
	# Make sure all nodes have been readied and scripts loaded before running signals
	if not get_tree().root.is_node_ready():
		await get_tree().root.ready

	get_tree().call_group(group, "signal_" + signal_name)


func send_signal_to_node(path: NodePath, signal_name: String):
	# Make sure all nodes have been readied and scripts loaded before running signals
	if not get_tree().root.is_node_ready():
		await get_tree().root.ready

	var node = get_node(path)
	if node:
		node.call("signal_" + signal_name)
