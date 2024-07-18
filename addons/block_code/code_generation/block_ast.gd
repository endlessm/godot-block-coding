class_name BlockAST
extends Object

var root: ASTNode


class ASTNode:
	var data  #: BlockStatementResource
	var children: Array[ASTNode]
	var arguments: Dictionary  # String, ASTValueNode

	func _init():
		children = []
		arguments = {}

	func get_code(depth: int) -> String:
		var code: String = ""
		var block_code: String = data.generate_code()  # generate multiline string from statementblock

		block_code = block_code.indent("\t".repeat(depth))

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

			block_code = block_code.replace("{%s}" % arg_name, code_string)

		# append code block

		code += block_code + "\n"

		for child in children:
			code += child.get_code(depth + 1)

		return code


class ASTValueNode:
	var data  #: BlockValueResource
	var arguments: Dictionary  # String, ASTValueNode

	func _init():
		arguments = {}

	func get_code() -> String:
		var code: String = data.statement  # statement will be just value if literal

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

		return "(%s)" % code


func get_code() -> String:
	return root.get_code(0)


func _to_string():
	return to_string_recursive(root, 0)


func to_string_recursive(node: ASTNode, depth: int) -> String:
	var string: String = "%s %s\n" % ["-".repeat(depth), node.data.block_format]

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
