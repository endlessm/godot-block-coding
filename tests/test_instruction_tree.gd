extends GutTest
## Tests for InstructionTree

const CategoryFactory = preload("res://addons/block_code/ui/picker/categories/category_factory.gd")
const InstructionTree = preload("res://addons/block_code/instruction_tree/instruction_tree.gd")

var general_blocks: Dictionary


func build_block_map(block_map: Dictionary, blocks: Array[Block]):
	assert_eq(block_map, {})
	for block in blocks:
		assert_does_not_have(block_map, block.block_name, "Block name %s is duplicated" % block.block_name)
		block_map[block.block_name] = block


func free_block_map(block_map: Dictionary):
	for block in block_map.values():
		block.free()
	block_map.clear()
	assert_eq(block_map, {})


func dup_node(node: Node) -> Node:
	return node.duplicate(DUPLICATE_USE_INSTANTIATION)


func before_each():
	build_block_map(general_blocks, CategoryFactory.get_general_blocks())


func after_each():
	free_block_map(general_blocks)


func test_single_node_text():
	var node = InstructionTree.TreeNode.new("blah")
	var text: String = InstructionTree.generate_text(node, 0)
	assert_eq(text, "blah\n")


func test_root_depth_text():
	var node = InstructionTree.TreeNode.new("blah")
	var text: String
	for depth in range(5):
		text = InstructionTree.generate_text(node, depth)
		assert_eq(text, "\t".repeat(depth) + "blah\n")


func test_child_node_text():
	var parent = InstructionTree.TreeNode.new("parent")
	var child = InstructionTree.TreeNode.new("child")
	var grandchild = InstructionTree.TreeNode.new("grandchild")
	parent.add_child(child)
	child.add_child(grandchild)
	var text: String = InstructionTree.generate_text(parent, 0)
	assert_eq(text, "parent\n\tchild\n\t\tgrandchild\n")


func test_sibling_node_text():
	var node = InstructionTree.TreeNode.new("node")
	var brother = InstructionTree.TreeNode.new("brother")
	var sister = InstructionTree.TreeNode.new("sister")
	node.next = brother
	brother.next = sister
	var text: String = InstructionTree.generate_text(node, 0)
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

	var text: String = InstructionTree.generate_text(root, 0)
	assert_eq(text, "root\n\tchild1\n\t\tgrandchild\n\tchild2\nsibling\n\tnephew\n")


func test_script_no_nodes():
	var bsd := BlockScriptData.new("Foo")
	var script := InstructionTree.generate_script_from_nodes([], bsd)
	assert_eq(
		script,
		(
			"""\
			extends Foo


			"""
			. dedent()
		)
	)


func test_script_no_entry_blocks():
	var bsd := BlockScriptData.new("Foo")
	var nodes: Array[Node] = [Node.new(), Node2D.new(), Control.new()]
	var script := InstructionTree.generate_script_from_nodes(nodes, bsd)
	assert_eq(
		script,
		(
			"""\
			extends Foo


			"""
			. dedent()
		)
	)
	for node in nodes:
		node.free()


func test_basic_script():
	var ready_block: Block = dup_node(general_blocks["ready_block"])

	var print_block: Block = dup_node(general_blocks["print"])
	# XXX: It seems like this should substitute {text} in the statement,
	# but it doesn't. I can't make sense of StatementBlock.
	# print_block.param_input_strings = {"text": "this is a test"}
	# print_block._ready()

	# XXX: Why does insert_snapped_block add_child but not set snapped_block?
	ready_block.bottom_snap.insert_snapped_block(print_block)
	ready_block.bottom_snap.snapped_block = print_block
	assert_true(ready_block.bottom_snap.has_snapped_block())
	assert_eq(ready_block.bottom_snap.get_snapped_block(), print_block)

	var bsd := BlockScriptData.new("Node2D")
	var script := InstructionTree.generate_script_from_nodes([ready_block], bsd)
	assert_eq(
		script,
		(
			"""\
			extends Node2D


			func _ready():
				print({text})

			"""
			. dedent()
		)
	)

	ready_block.free()


func test_multiple_entry_script():
	var ready_block: Block = dup_node(general_blocks["ready_block"])
	var print_block: Block = dup_node(general_blocks["print"])
	ready_block.bottom_snap.insert_snapped_block(print_block)
	ready_block.bottom_snap.snapped_block = print_block

	var ready_block_2: Block = dup_node(ready_block)

	var bsd := BlockScriptData.new("Node2D")
	var script := InstructionTree.generate_script_from_nodes([ready_block, ready_block_2], bsd)
	assert_eq(
		script,
		(
			"""\
			extends Node2D


			func _ready():
				print({text})

				print({text})

			"""
			. dedent()
		)
	)

	ready_block.free()
	ready_block_2.free()


func test_signal_script():
	var area2d_blocks: Dictionary
	build_block_map(area2d_blocks, CategoryFactory.get_inherited_blocks("Area2D"))
	var entered_block: Block = dup_node(area2d_blocks["area2d_on_entered"])
	var print_block: Block = dup_node(general_blocks["print"])
	entered_block.bottom_snap.insert_snapped_block(print_block)
	entered_block.bottom_snap.snapped_block = print_block

	var bsd := BlockScriptData.new("Area2D")
	var script = InstructionTree.generate_script_from_nodes([entered_block], bsd)
	assert_eq(
		script,
		(
			"""\
			extends Area2D



			func _on_body_entered(_body: Node2D):
				var body: NodePath = _body.get_path()

				print({text})

			func _init():
				body_entered.connect(_on_body_entered)
			"""
			. dedent()
		)
	)

	entered_block.free()
	free_block_map(area2d_blocks)
