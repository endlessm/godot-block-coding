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
