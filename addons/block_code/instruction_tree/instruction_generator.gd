class_name InstructionGenerator
extends Object

var depth: int
var out: String

# TODO: Make iterative?
func generate_string(root: Block) -> String:
	depth = 0
	out = ""
	generate_string_recursive(root)
	return out

func generate_string_recursive(root: Block):
	for i in depth:
		out += "\t"
	out += root.get_instruction() + "\n"
	
	depth += 1
	
	for c in root.get_child_blocks():
		generate_string_recursive(c)
	
	depth -= 1
