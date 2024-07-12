@tool
class_name NodeBlockCanvas
extends BlockCanvas


func generate_script_from_current_window(bsd: BlockScriptData):
	# TODO: implement multiple windows
	return InstructionTree.generate_script_from_nodes(_window.get_children(), bsd)
