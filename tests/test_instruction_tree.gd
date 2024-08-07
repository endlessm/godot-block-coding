extends GutTest
## Tests for Script Generation

const Types = preload("res://addons/block_code/types/types.gd")
const ScriptGenerator = preload("res://addons/block_code/code_generation/script_generator.gd")
const ASTList = preload("res://addons/block_code/code_generation/ast_list.gd")
const BlockAST = preload("res://addons/block_code/code_generation/block_ast.gd")
const BlockDefinition = preload("res://addons/block_code/code_generation/block_definition.gd")

var general_blocks: Dictionary


func build_block_map(block_map: Dictionary, blocks: Array[BlockDefinition]):
	assert_eq(block_map, {})
	for block in blocks:
		assert_does_not_have(block_map, block.name, "Block name %s is duplicated" % block.name)
		block_map[block.name] = block


func free_block_map(block_map: Dictionary):
	block_map.clear()
	assert_eq(block_map, {})


func before_all():
	CategoryFactory.init_block_definition_dictionary()


func before_each():
	build_block_map(general_blocks, CategoryFactory.get_general_blocks())


func after_each():
	free_block_map(general_blocks)


func block_resource_from_code_template(code_template: String) -> BlockDefinition:
	var block_resource = BlockDefinition.new()
	block_resource.code_template = code_template
	return block_resource


func ast_node_from_code_template(code_template: String) -> BlockAST.ASTNode:
	var node = BlockAST.ASTNode.new()
	node.data = block_resource_from_code_template(code_template)
	return node


func test_single_node_text():
	var node = ast_node_from_code_template("blah")
	var text: String = node.get_code(0)
	assert_eq(text, "blah\n")


func test_root_depth_text():
	var node = ast_node_from_code_template("blah")
	var text: String
	for depth in range(5):
		text = node.get_code(depth)
		assert_eq(text, "\t".repeat(depth) + "blah\n")


func test_child_node_text():
	var parent = ast_node_from_code_template("parent")
	var child = ast_node_from_code_template("child")
	var grandchild = ast_node_from_code_template("grandchild")
	parent.children.append(child)
	child.children.append(grandchild)
	var text: String = parent.get_code(0)
	assert_eq(text, "parent\n\tchild\n\t\tgrandchild\n")


func test_sibling_node_text():
	var parent = ast_node_from_code_template("parent")
	var brother = ast_node_from_code_template("brother")
	var sister = ast_node_from_code_template("sister")
	parent.children.append(brother)
	parent.children.append(sister)
	var text: String = parent.get_code(0)
	assert_eq(text, "parent\n\tbrother\n\tsister\n")


## Test recursive node first, depth first text generation.
func test_tree_node_text():
	var root = ast_node_from_code_template("root")
	var parent = ast_node_from_code_template("parent")
	var child1 = ast_node_from_code_template("child1")
	var child2 = ast_node_from_code_template("child2")
	var grandchild = ast_node_from_code_template("grandchild")
	var sibling = ast_node_from_code_template("sibling")
	var nephew = ast_node_from_code_template("nephew")

	root.children.append(parent)
	parent.children.append(child1)
	parent.children.append(child2)
	child1.children.append(grandchild)
	root.children.append(sibling)
	sibling.children.append(nephew)

	var text: String = root.get_code(0)
	assert_eq(text, "root\n\tparent\n\t\tchild1\n\t\t\tgrandchild\n\t\tchild2\n\tsibling\n\t\tnephew\n")


func test_script_no_nodes():
	var bsd := BlockScriptSerialization.new("Foo")
	var script := ScriptGenerator.generate_script(ASTList.new(), bsd)
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
	var bsd := BlockScriptSerialization.new("Foo")
	var ast := BlockAST.new()
	ast.root = BlockAST.ASTNode.new()
	ast.root.data = BlockDefinition.new()
	ast.root.data.type = Types.BlockType.STATEMENT
	var ast_list = ASTList.new()
	ast_list.append(ast, Vector2(0, 0))
	var script := ScriptGenerator.generate_script(ast_list, bsd)
	assert_eq(
		script,
		(
			"""\
			extends Foo


			"""
			. dedent()
		)
	)


func test_basic_script():
	var ready_block = general_blocks["ready"]
	var print_block = general_blocks["print"]

	var ast := BlockAST.new()
	ast.root = BlockAST.ASTNode.new()
	ast.root.data = ready_block
	ast.root.children.append(BlockAST.ASTNode.new())
	ast.root.children[0].data = print_block
	ast.root.children[0].arguments["text"] = "Hello world!"
	var ast_list = ASTList.new()
	ast_list.append(ast, Vector2(0, 0))

	var bsd := BlockScriptSerialization.new("Node2D")
	var script := ScriptGenerator.generate_script(ast_list, bsd)
	assert_eq(
		script,
		(
			"""\
			extends Node2D


			func _ready():
				print('Hello world!')

			"""
			. dedent()
		)
	)


func test_multiple_entry_script():
	var ready_block = general_blocks["ready"]
	var print_block = general_blocks["print"]

	var ast := BlockAST.new()
	ast.root = BlockAST.ASTNode.new()
	ast.root.data = ready_block
	ast.root.children.append(BlockAST.ASTNode.new())
	ast.root.children[0].data = print_block
	ast.root.children[0].arguments["text"] = "Hello world!"
	var ast_list = ASTList.new()
	ast_list.append(ast, Vector2(0, 0))
	ast_list.append(ast, Vector2(0, 0))

	var bsd := BlockScriptSerialization.new("Node2D")
	var script := ScriptGenerator.generate_script(ast_list, bsd)
	assert_eq(
		script,
		(
			"""\
			extends Node2D


			func _ready():
				print('Hello world!')
				print('Hello world!')

			"""
			. dedent()
		)
	)


func test_signal_script():
	var area2d_blocks: Dictionary
	build_block_map(area2d_blocks, CategoryFactory.get_inherited_blocks("Area2D"))

	var entered_block: BlockDefinition = area2d_blocks["area2d_on_entered"]
	var print_block: BlockDefinition = general_blocks["print"]

	var ast := BlockAST.new()
	ast.root = BlockAST.ASTNode.new()
	ast.root.data = entered_block
	ast.root.children.append(BlockAST.ASTNode.new())
	ast.root.children[0].data = print_block
	ast.root.children[0].arguments["text"] = "Body entered!"
	var ast_list = ASTList.new()
	ast_list.append(ast, Vector2(0, 0))

	var bsd := BlockScriptSerialization.new("Area2D")
	var script := ScriptGenerator.generate_script(ast_list, bsd)
	assert_eq(
		script,
		(
			"""\
			extends Area2D


			func _init():
				body_entered.connect(_on_body_entered)

			func _on_body_entered(body: Node):
				print('Body entered!')

			"""
			. dedent()
		)
	)

	free_block_map(area2d_blocks)
