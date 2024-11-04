## BlockCode update translated files script
##
## Use this on the Godot command line with the --script option.
extends SceneTree

const TxUtils := preload("res://addons/block_code/translation/utils.gd")


func _init():
	TxUtils.update_pot_files()
	quit()
