## BlockCode POT regeneration script
##
## Use this on the Godot command line with the --script option. This depends on
## the Godot editor, so the --editor option is also required.
extends SceneTree

const TxUtils := preload("res://addons/block_code/translation/utils.gd")


# Everything happens in _process to ensure the editor is fully initialized.
func _process(_delta):
	if Engine.is_editor_hint():
		TxUtils.regenerate_pot_file()
	else:
		push_error("%s can only be run with --editor" % get_script().resource_path)

	# Stop processing the main loop.
	return true


# The editor won't be shut down in the normal way, which will cause a bunch of
# leaks. There's nothing we can do about that and we don't care about them,
# anyways. Let the user following along know this is OK.
func _finalize():
	print_rich("[b]%s causes Godot to leak resources. Ignore the warnings and errors![/b]" % get_script().resource_path.get_file())
