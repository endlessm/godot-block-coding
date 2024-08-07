extends Object


## Returns the scope of the first non-empty scope child block
static func get_tree_scope(node: Node) -> String:
	if node is Block:
		if node.definition.scope != "":
			return node.definition.scope

	for c in node.get_children():
		var scope := get_tree_scope(c)
		if scope != "":
			return scope
	return ""


## Get the nearest Block node that is a parent of the provided node.
static func get_parent_block(node: Node) -> Block:
	var parent = node.get_parent()
	while parent and not parent is Block:
		parent = parent.get_parent()
	return parent as Block
