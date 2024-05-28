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


func generate_tree(root_block: Block) -> TreeNode:
	return root_block.get_instruction()


func generate_text(root_node: TreeNode) -> String:
	out = ""
	depth = 0
	generate_text_recursive(root_node)
	return out


func generate_text_recursive(root_node: TreeNode):
	for i in depth:
		out += "\t"
	out += root_node.data + "\n"

	depth += 1

	for c in root_node.children:
		generate_text_recursive(c)

	depth -= 1

	if root_node.next:
		generate_text_recursive(root_node.next)
