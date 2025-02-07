extends Node

enum BlockType {
	NONE,  ## @deprecated
	ENTRY,  ## A block that's the entry point. Statement or control blocks can be attached below it.
	STATEMENT,  ## A block that executes a statement. Another statement or control block can be attached below it.
	VALUE,  ## A block that represents a value. It could be a constant or the result of an operation. All blocks may have slots to attach value blocks in their body.
	CONTROL,  ## A block that can conditionally execute other statement or control blocks. Another statement or control block can be attached below it.
}

const VARIANT_TYPE_TO_STRING: Dictionary = {
	TYPE_STRING: "STRING",
	TYPE_INT: "INT",
	TYPE_FLOAT: "FLOAT",
	TYPE_BOOL: "BOOL",
	TYPE_VECTOR2: "VECTOR2",
	TYPE_VECTOR3: "VECTOR3",
	TYPE_COLOR: "COLOR",
	TYPE_NODE_PATH: "NODE_PATH",
	TYPE_OBJECT: "OBJECT",
	TYPE_NIL: "NIL",
	TYPE_STRING_NAME: "STRING_NAME",
}

const STRING_TO_VARIANT_TYPE: Dictionary = {
	"STRING": TYPE_STRING,
	"INT": TYPE_INT,
	"FLOAT": TYPE_FLOAT,
	"BOOL": TYPE_BOOL,
	"VECTOR2": TYPE_VECTOR2,
	"VECTOR3": TYPE_VECTOR3,
	"COLOR": TYPE_COLOR,
	"NODE_PATH": TYPE_NODE_PATH,
	"OBJECT": TYPE_OBJECT,
	"NIL": TYPE_NIL,
	"STRING_NAME": TYPE_STRING_NAME,
}

const types_relationships = {
	TYPE_INT: [TYPE_FLOAT],
	TYPE_FLOAT: [TYPE_INT],
	TYPE_BOOL: [TYPE_STRING, TYPE_INT, TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR, TYPE_NODE_PATH, TYPE_OBJECT, TYPE_NIL, TYPE_STRING_NAME],
}


static func has_relationship(type: Variant.Type, parent_type: Variant.Type) -> bool:
	if type == parent_type:
		return true
	return type in types_relationships.get(parent_type, [])
