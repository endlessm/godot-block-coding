class_name InstructionTree
extends Object


class TreeNode:
	var data: String
	var children: Array[TreeNode]
	var next: TreeNode

	func _init(_data: String):
		data = _data

	func add_child(node: TreeNode):
		children.append(node)


class IDHandler:
	static var counts: Dictionary = {}

	static func reset():
		counts = {}

	static func get_unique_id(str: String) -> int:
		if not counts.has(str):
			counts[str] = 0

		counts[str] += 1

		return counts[str]

	static func make_unique(formatted_string: String) -> String:
		var unique_string = formatted_string
		var regex = RegEx.new()
		regex.compile("[^\\s]+__\\b")
		var ids: Dictionary = {}
		for result in regex.search_all(formatted_string):
			var result_string = result.get_string()
			var base_string = result_string.trim_suffix("__")
			if not ids.has(base_string):
				ids[base_string] = get_unique_id(base_string)
			unique_string = unique_string.replace(result_string, base_string + "_%d" % ids[base_string])

		return unique_string


func generate_text(root_node: TreeNode, start_depth: int = 0) -> String:
	var out = PackedStringArray()
	generate_text_recursive(root_node, start_depth, out)
	return "".join(out)


func generate_text_recursive(node: TreeNode, depth: int, out: PackedStringArray):
	if node.data != "":
		out.append("\t".repeat(depth) + node.data + "\n")

	for c in node.children:
		generate_text_recursive(c, depth + 1, out)

	if node.next:
		generate_text_recursive(node.next, depth, out)
