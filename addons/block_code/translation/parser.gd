@tool
## BlockCode translation parser plugin.
##
## Extracts translatable strings from BlockCode resources. Currently only
## BlockDefinition resources are handled.
extends EditorTranslationParserPlugin

const BLOCK_DEFINITION_SCRIPT_PATH := "res://addons/block_code/code_generation/block_definition.gd"

# BlockDefinition properties for translation
const block_def_tx_properties: Array[String] = [
	"category",
	"description",
	"display_template",
]


func _get_recognized_extensions() -> PackedStringArray:
	# BlockDefinition resources currently use the generic tres extension.
	return ["tres"]


func _resource_is_block_definition(resource: Resource) -> bool:
	var script := resource.get_script()
	if not script:
		return false
	return script.resource_path == BLOCK_DEFINITION_SCRIPT_PATH


func _parse_file(path: String) -> Array[PackedStringArray]:
	# Only BlockDefinition resources are supported.
	var res = ResourceLoader.load(path, "Resource")
	if not res or not _resource_is_block_definition(res):
		return []
	# Each entry should contain [msgid, msgctxt, msgid_plural, comment],
	# where all except msgid are optional.
	var ret: Array[PackedStringArray] = []
	for prop in block_def_tx_properties:
		var value: String = res.get(prop)
		if value:
			# For now just the messages are used. It might be better to provide
			# context with msgids_context_plural to avoid conflicts.
			ret.append(PackedStringArray([value]))
	return ret
