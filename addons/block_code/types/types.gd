extends Node

enum BlockType {
	NONE,
	ENTRY,
	STATEMENT,
	VALUE,
	CONTROL,
}

const VARIANT_TYPE_TO_STRING: Dictionary = {
	TYPE_STRING: "STRING",
	TYPE_INT: "INT",
	TYPE_FLOAT: "FLOAT",
	TYPE_BOOL: "BOOL",
	TYPE_VECTOR2: "VECTOR2",
	TYPE_COLOR: "COLOR",
	TYPE_NODE_PATH: "NODE_PATH",
	TYPE_OBJECT: "OBJECT",
	TYPE_NIL: "NIL",
}

const STRING_TO_VARIANT_TYPE: Dictionary = {
	"STRING": TYPE_STRING,
	"INT": TYPE_INT,
	"FLOAT": TYPE_FLOAT,
	"BOOL": TYPE_BOOL,
	"VECTOR2": TYPE_VECTOR2,
	"COLOR": TYPE_COLOR,
	"NODE_PATH": TYPE_NODE_PATH,
	"OBJECT": TYPE_OBJECT,
	"NIL": TYPE_NIL,
}

const cast_relationships = [
	[TYPE_INT, TYPE_FLOAT, "float(%s)"],
	[TYPE_FLOAT, TYPE_INT, "int(%s)"],
	[TYPE_INT, TYPE_STRING, "str(%s)"],
	[TYPE_FLOAT, TYPE_STRING, "str(%s)"],
	[TYPE_COLOR, TYPE_STRING, "str(%s)"],
	[TYPE_VECTOR2, TYPE_STRING, "str(%s)"],
]

# Directed graph, edges are CastGraphEdge
static var cast_graph: Dictionary


class CastGraphEdge:
	var to: Variant.Type
	var cast_format: String

	func _init(p_to: Variant.Type, p_cast_format: String):
		to = p_to
		cast_format = p_cast_format


static func init_cast_graph():
	cast_graph = {}

	for rel in cast_relationships:
		if not cast_graph.has(rel[0]):
			cast_graph[rel[0]] = []

		if not cast_graph.has(rel[1]):
			cast_graph[rel[1]] = []

		var edges: Array = cast_graph[rel[0]]

		edges.append(CastGraphEdge.new(rel[1], rel[2]))


# Graph recursive utils
static var prev: Dictionary
static var dist: Dictionary
const INT_MAX: int = 1000000000


static func dijkstra(source: Variant.Type):
	prev = {}
	dist = {}

	var queue := PriorityQueue.new()

	dist[source] = 0
	queue.push(source, 0)

	for v in cast_graph.keys():
		if v != source:
			dist[v] = INT_MAX
			prev[v] = null
			queue.push(v, INT_MAX)

	while not queue.is_empty():
		var u = queue.pop()

		if !cast_graph.has(u):
			continue

		for edge in cast_graph[u]:
			var v = edge.to
			var alt = dist[u] + 1
			if alt < dist[v]:
				dist[v] = alt
				prev[v] = CastGraphEdge.new(u, edge.cast_format)
				queue.update_priority(v, alt)


static func can_cast(type: Variant.Type, parent_type: Variant.Type) -> bool:
	if type == parent_type:
		return true

	if cast_graph.has(type) and cast_graph.has(parent_type):
		dijkstra(type)
		return dist[parent_type] < INT_MAX
	return false


static func cast(val: String, type: Variant.Type, parent_type: Variant.Type):
	if type == parent_type:
		return val

	if cast_graph.has(type) and cast_graph.has(parent_type):
		dijkstra(type)
		if dist[parent_type] < INT_MAX:
			var prev_edge = prev[parent_type]
			var cast_string = "%s"
			while prev_edge:
				cast_string %= prev_edge.cast_format
				if prev.has(prev_edge.to):
					prev_edge = prev[prev_edge.to]
				else:
					prev_edge = null

			return cast_string % val

	return null


# TODO: replace with max heap
class PriorityQueue:
	var data: Array = []

	func _init():
		data = []

	func push(element, priority):
		data.append([element, priority])
		_sort()

	func _sort():
		data.sort_custom(func(a, b): a[1] < b[1])

	func pop():
		if data.size() > 0:
			return data.pop_front()[0]
		return null

	func peek():
		if data.size() > 0:
			return data[0][0]
		return null

	func is_empty():
		return data.size() == 0

	func update_priority(element, priority):
		var found_pair = null
		for pair in data:
			if pair[0] == element:
				found_pair = pair
				break

		if found_pair:
			found_pair[1] = priority
			_sort()
