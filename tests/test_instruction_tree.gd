extends GutTest
## Tests for InstructionTree

var tree: InstructionTree = null


func before_each():
	tree = InstructionTree.new()


func after_each():
	if tree != null:
		tree.free()
		tree = null


func test_single_node_text():
	var node = InstructionTree.TreeNode.new("blah")
	var text: String = tree.generate_text(node, 0)
	assert_eq(text, "blah\n")


func test_root_depth_text():
	var node = InstructionTree.TreeNode.new("blah")
	var text: String
	for depth in range(5):
		text = tree.generate_text(node, depth)
		assert_eq(text, "\t".repeat(depth) + "blah\n")


func test_child_node_text():
	var parent = InstructionTree.TreeNode.new("parent")
	var child = InstructionTree.TreeNode.new("child")
	var grandchild = InstructionTree.TreeNode.new("grandchild")
	parent.add_child(child)
	child.add_child(grandchild)
	var text: String = tree.generate_text(parent, 0)
	assert_eq(text, "parent\n\tchild\n\t\tgrandchild\n")


func test_sibling_node_text():
	var node = InstructionTree.TreeNode.new("node")
	var brother = InstructionTree.TreeNode.new("brother")
	var sister = InstructionTree.TreeNode.new("sister")
	node.next = brother
	brother.next = sister
	var text: String = tree.generate_text(node, 0)
	assert_eq(text, "node\nbrother\nsister\n")


## Test recursive node first, depth first text generation.
func test_tree_node_text():
	var root = InstructionTree.TreeNode.new("root")
	var child1 = InstructionTree.TreeNode.new("child1")
	var child2 = InstructionTree.TreeNode.new("child2")
	var grandchild = InstructionTree.TreeNode.new("grandchild")
	var sibling = InstructionTree.TreeNode.new("sibling")
	var nephew = InstructionTree.TreeNode.new("nephew")

	root.add_child(child1)
	root.add_child(child2)
	child1.add_child(grandchild)
	root.next = sibling
	sibling.add_child(nephew)

	var text: String = tree.generate_text(root, 0)
	assert_eq(text, "root\n\tchild1\n\t\tgrandchild\n\tchild2\nsibling\n\tnephew\n")


func test_error():
	assert_eq("a", "b")
