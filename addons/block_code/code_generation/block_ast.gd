extends RefCounted

const BlockAST = preload("res://addons/block_code/code_generation/block_ast.gd")
const OptionData = preload("res://addons/block_code/code_generation/option_data.gd")
const Types = preload("res://addons/block_code/types/types.gd")

var root: ASTNode


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
		regex.compile("\\b__[^\\s]+")
		var ids: Dictionary = {}
		for result in regex.search_all(formatted_string):
			var result_string = result.get_string()
			if not ids.has(result_string):
				ids[result_string] = get_unique_id(result_string)
				unique_string = unique_string.replace(result_string, result_string + "_%d" % ids[result_string])

		return unique_string


class ASTNode:
	var data  #: BlockDefinition
	var children: Array[ASTNode]
	var arguments: Dictionary  # String, ASTValueNode

	func _init():
		children = []
		arguments = {}

	func get_code_block() -> String:
		var code_block: String = data.code_template  # get multiline code_template from block definition

		# insert args

		# check if args match an overload in the resource

		for arg_name in arguments:
			# Use parentheses to be safe
			var argument = arguments[arg_name]
			var code_string: String
			if argument is ASTValueNode:
				code_string = argument.get_code()
			else:
				code_string = BlockAST.raw_input_to_code_string(argument)

			code_block = code_block.replace("{%s}" % arg_name, code_string)

		return IDHandler.make_unique(code_block)

	func get_code(depth: int) -> String:
		var code: String = ""

		# append code block
		var code_block := get_code_block()
		code_block = code_block.indent("\t".repeat(depth))

		code += code_block + "\n"

		# fill empty entry and control blocks with pass
		if children.is_empty() and (data.type == Types.BlockType.ENTRY || data.type == Types.BlockType.CONTROL):
			code += "pass\n".indent("\t".repeat(depth + 1))

		for child in children:
			code += child.get_code(depth + 1)

		return code


class ASTValueNode:
	var data  #: BlockDefinition
	var arguments: Dictionary  # String, ASTValueNode

	func _init():
		arguments = {}

	func get_code() -> String:
		var code: String = data.code_template  # get code_template from block definition

		# check if args match an overload in the resource

		for arg_name in arguments:
			# Use parentheses to be safe
			var argument = arguments[arg_name]
			var code_string: String
			if argument is ASTValueNode:
				code_string = argument.get_code()
			else:
				code_string = BlockAST.raw_input_to_code_string(argument)

			code = code.replace("{%s}" % arg_name, code_string)

		return IDHandler.make_unique("(%s)" % code)


func get_code() -> String:
	IDHandler.reset()
	return root.get_code(0)


func _to_string():
	return to_string_recursive(root, 0)


func to_string_recursive(node: ASTNode, depth: int) -> String:
	var string: String = "%s %s\n" % ["-".repeat(depth), node.data.display_template]

	for c in node.children:
		string += to_string_recursive(c, depth + 1)

	return string


static func raw_input_to_code_string(input) -> String:
	match typeof(input):
		TYPE_STRING:
			return "'%s'" % input.replace("\\", "\\\\").replace("'", "\\'")
		TYPE_VECTOR2:
			return "Vector2%s" % str(input)
		TYPE_COLOR:
			return "Color%s" % str(input)
		TYPE_OBJECT:
			if input is OptionData:
				var option_data := input as OptionData
				return option_data.items[option_data.selected]
		_:
			return "%s" % input

	return ""
