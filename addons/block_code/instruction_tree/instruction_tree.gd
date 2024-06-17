class_name InstructionTree
extends Object

var depth: int
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
	depth = start_depth
	generate_text_recursive(root_node)
	return out


func generate_text_recursive(root_node: TreeNode):
	if root_node.data != "":
		for i in depth:
			out += "\t"
		out += root_node.data + "\n"

	depth += 1

	for c in root_node.children:
		generate_text_recursive(c)

	depth -= 1

	if root_node.next:
		generate_text_recursive(root_node.next)
