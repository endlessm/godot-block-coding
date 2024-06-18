class_name InstructionTree
extends Object

var out: String


class TreeNode:
	var data: String
	var children: Array[TreeNode]
	var next: TreeNode

	func _init(_data: String):
		data = _data

	func add_child(node: TreeNode):
		children.append(node)


func generate_text(root_node: TreeNode, start_depth: int = 0) -> String:
	out = ""
	generate_text_recursive(root_node, start_depth)
	return out


func generate_text_recursive(node: TreeNode, depth: int):
	if node.data != "":
		for i in depth:
			out += "\t"
		out += node.data + "\n"

	for c in node.children:
		generate_text_recursive(c, depth + 1)

	if node.next:
		generate_text_recursive(node.next, depth)
