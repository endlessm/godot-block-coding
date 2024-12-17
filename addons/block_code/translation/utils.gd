## BlockCode translation utilities.
extends Object

# FIXME: All of this depends on TranslationDomain support in Godot 4.4. When
# that's the minimum supported version, use regular method calls and add
# typing.

## BlockCode translation domain name
const DOMAIN := &"godot_block_coding"

## BlockCode locale directory path
const LOCALE_DIR_PATH := "res://addons/block_code/locale"

## BlockCode POT file path
const POT_FILE_PATH := "res://addons/block_code/locale/godot_block_coding.pot"

## ProjectSetting containing the POT files array
const POT_FILES_SETTING := "internationalization/locale/translations_pot_files"


## Get the BlockCode translation domain.
##
## The domain is only returned when running in the editor since the
## translations are only loaded by the editor plugin.
##
## Prior to Godot 4.4, this will return null.
static func get_domain():
	if not Engine.is_editor_hint():
		return null
	if not TranslationServer.has_method(&"get_or_add_domain"):
		return null
	return TranslationServer.call(&"get_or_add_domain", DOMAIN)


## Returns the BlockCode domain's translation for the message and context.
##
## This can be used in a static context instead of [method Object.tr]. When
## called outside of the editor, [method TranslationServer.translate] is used.
static func translate(message: StringName, context: StringName = &"") -> StringName:
	var domain = get_domain()
	if domain:
		return domain.translate(message, context)
	return TranslationServer.translate(message, context)


## Returns the BlockCode domain's translation for the message, plural message and context.
##
## This can be used in a static context instead of [method Object.tr_n]. When
## called outside of the editor, [method TranslationServer.translate_plural] is
## used.
static func translate_plural(message: StringName, message_plural: StringName, n: int, context: StringName = &"") -> StringName:
	var domain = get_domain()
	if domain:
		return domain.translate_plural(message, message_plural, n, context)
	return TranslationServer.translate_plural(message, message_plural, n, context)


## Load BlockCode translations.
##
## Loads all PO files in the locale directory and adds them to the BlockCode
## translation domain.
##
## This function has no effect prior to Godot 4.4.
static func load_translations():
	var domain = get_domain()
	if not domain:
		return

	var locale_dir := DirAccess.open(LOCALE_DIR_PATH)
	if not locale_dir:
		push_warning("Could not open BlockCode locale directory %s" % LOCALE_DIR_PATH)
		return
	for name in locale_dir.get_files():
		if name.get_extension() != "po":
			continue
		var po_path := LOCALE_DIR_PATH.path_join(name)
		var po = load(po_path)
		if not po:
			push_warning("Could not load BlockCode translations from %s" % po_path)
			continue

		print_verbose("Adding %s %s translations from %s" % [DOMAIN, po.locale, po_path])
		domain.add_translation(po)


## Unload BlockCode translations.
##
## Clears all translations from the BlockCode translation domain.
##
## This function has no effect prior to Godot 4.4.
static func unload_translations():
	var domain = get_domain()
	if not domain:
		return

	print_verbose("Clearing all BlockCode translations")
	domain.clear()


## Set Object translation domain for BlockCode.
##
## This makes the object use the BlockCode translation domain. If the object is
## a Node, all of its descendents will inherit the translation domain by
## default. The domain is only set when running in the editor since the
## translations are only loaded by the editor plugin.
##
## This function has no effect prior to Godot 4.4.
static func set_block_translation_domain(obj: Object):
	if not Engine.is_editor_hint():
		return
	if obj.has_method(&"set_translation_domain"):
		print_verbose("Setting %s translation domain to %s" % [obj, DOMAIN])
		obj.call(&"set_translation_domain", DOMAIN)


## Regenerate BlockCode POT file.
##
## Update the BlockCode POT file to include new translatable strings.
static func regenerate_pot_file():
	# Dirty method to drive the editor's Generate POT dialog from
	# https://github.com/godotengine/godot-proposals/issues/10986#issuecomment-2419914451
	#
	# Obviously this is pretty fragile since it depends on the editor's UI
	# remaining stable. Hopefully in the future we can just do this from the
	# command line. See https://github.com/godotengine/godot/pull/98422.
	var localization := EditorInterface.get_base_control().find_child("*Localization*", true, false)
	var file_dialog: EditorFileDialog = localization.get_child(5)
	print(translate("Updating %s POT file %s") % ["BlockCode", POT_FILE_PATH])
	file_dialog.file_selected.emit(POT_FILE_PATH)


static func _add_pot_files_recursive(pot_files: PackedStringArray, path: String):
	# Make sure we're only operating in the block_code directory.
	if not path.begins_with("res://addons/block_code"):
		push_error("Cannot add POT files from %s" % path)
		return

	# Add specific file extensions to POT files.
	for name in DirAccess.get_files_at(path):
		if name.get_extension() in ["gd", "tres", "tscn"]:
			var child_path := path.path_join(name)
			print_verbose("Adding POT file %s" % child_path)
			pot_files.append(child_path)

	# Descend to subdirs.
	for name in DirAccess.get_directories_at(path):
		_add_pot_files_recursive(pot_files, path.path_join(name))


## Update BlockCode POT files.
##
## Update the array of POT files for the BlockCode plugin. All gd, tres
## and tscn files in the plugin are added.
static func update_pot_files():
	var pot_files: PackedStringArray
	_add_pot_files_recursive(pot_files, "res://addons/block_code")
	print(translate("Updating POT files setting %s") % POT_FILES_SETTING)
	ProjectSettings.set_setting(POT_FILES_SETTING, pot_files)
	ProjectSettings.save()
