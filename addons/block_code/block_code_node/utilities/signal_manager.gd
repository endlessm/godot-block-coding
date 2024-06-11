extends Node


func broadcast_signal(group: String, signal_name: String):
	# Make sure all nodes have been readied and scripts loaded before running signals
	if not get_tree().root.is_node_ready():
		await get_tree().root.ready

	get_tree().call_group(group, "signal_" + signal_name)
