# Block Programming Plugin

## Data flow/Hierarchy

1. The plugin enters at `block_code_plugin.gd` (`BlockCodePlugin`) where the `MainPanel` is initialized and added as a main screen tab labeled "Block Code".
	* The `MainPanel` contains a block `Picker`, a `BlockCanvas`, a `TitleBar`, and a `DragManager`.
		* The `Picker` contains a combined list of categories of blocks from the global blocks generated in `CategoryFactory`, and custom blocks defined in the class the script is attached to.
		* The `BlockCanvas` is where placed blocks live, and generates the code from the scene tree of blocks.
		* The `TitleBar` displays some information about the block script.
		* The `DragManager` determines how blocks are snapped, and what happens when you drag a block from either the `Picker` or the `BlockCanvas`

2. When a `BlockCode` node is selected, the `MainPanel` supplies the `Picker`, `BlockCanvas`, and `TitleBar` with the `BlockScriptData` (BSD) attached to the `BlockCode` node you clicked.
	* The `Picker` will be loaded with blocks, and any custom blocks supplied by the parent of the `BlockCode` node you clicked.
	* The `BlockCanvas` will be populated with the block scene tree deserialized from the BSD (`BlockScriptData.block_trees`).
	* The `TitleBar` will be populated with the name of class the script inherits.
	* If the BSD is `null`, it will copy and load the default one.

3. When you click and drag a block from the `Picker`, the `DragManager` is signaled to copy the block and enables you to drag it to the `BlockCanvas`.

4. The `DragManager` looks for the closest compatible snap point within a certain range, and if it exists, will show a preview where your `Block` will go if you drop it.
	* Each `Block` has a `block_type` property, and so does each snap point. They must match to snap.
	* If a `Block` has the block type `VALUE`, it should have a `variant_type` property (since it represents a value).
		* If it is a `VALUE` block, it's `variant_type` must be able to cast to the snap point's `variant_type` in order to snap. This is determined by the cast graph in `types.gd`.
		* Each `ParameterBlock` is a `VALUE` block which has this `variant_type` property.

5. When the block script is modified, it will regenerate the BSD, and save it as an exported property of the `BlockCode` node you are working on. This way it gets saved to the scene.
	* The block script is modified when a block is moved, or a `ParameterInput`'s raw input has been changed.
	* Code is generated whenever you modify the block in `BlockCanvas`.

6. When you play the scene, each `BlockCode` node will attach a generated script from it's BSD to it's parent node. The `_ready` and `_process` methods will start normally.

## How to create a new block

Blocks are created from a template such as `StatementBlock`, `ParameterBlock`, `EntryBlock`, or `ControlBlock`. Blocks are defined programmatically and generated live, they are not saved permanently in any sort of class.
* `StatementBlock`: Generates a line of code to be executed. Has notches to snap other statement blocks to. Supports input parameters.
* `ParameterBlock`: Represents a value, or expression in some code. Can be used as input for any statement blocks, or other parameter blocks that also take input.
* `EntryBlock`: Generates a method header, entry point to block script. Also supports input parameters.
* `ControlBlock`: Dictates the flow of instruction, such as a loop or if/else statement. Can have multiple slots for calling different statements based on a conditional input.

You can define a block:
1. Globally in `CategoryFactory.get_general_blocks()`
2. For a specific built-in class in `CategoryFactory.get_built_in_blocks()`
3. In a custom class by defining a method `static func get_custom_blocks() -> Array[Block]:`. See `SimpleCharacter` for an example.

Here is an example of generating a `STATEMENT` block:
```
# Instantiate the template block. In this case we use a StatementBlock since we want to generate a statement from some parameter inputs.
var b = BLOCKS["statement_block"].instantiate()

# Define the block format string. This is how the block will be rendered, with some text and two typed inputs.
# Inputs are specified as {parameter_name: TYPE}
b.block_format = "Set Int {var: STRING} {value: INT}"

# Define the statement that will be generated from the inputs. Use the parameter name to specify which goes where.
b.statement = "VAR_DICT[{var}] = {value}"

# Set the category too add the block to.
b.category = "Variables"
```
Look in `CategoryFactory` for more examples!

Each block gets added to a category in the Block Code editor by setting
the block's `category` property. If you have a custom class, you can add
a new category by defining a method `static func get_custom_categories()
-> Array[BlockCategory]:`. See `Pong` for an example.

Note: For `EntryBlock`s, you can use the syntax `[param: TYPE]` with square brackets instead of curlies to generate a copyable `ParameterBlock` that can be used in the below method.
For example, to expose the `delta` argument in `func _on_process(delta):`, you would use the following format string:
```
b.block_format = "On Process [delta: FLOAT]"
```

## What's inside?

* `/addons/block_code/`: The main plugin folder.
	* `block_code_plugin.gd`: The entry point to the editor plugin. Sets up the `MainPanel` scene which appears as a main screen tab at the top.
	* `/block_code_node/`: Contains the script for our custom `BlockCode` node that allows you to attach block scripts to a node. You can instantiate it in the scene dock.
	* `/block_script_data/`: Contains the custom resource that persists each block script. Each resource saves the class it inherits from, the generated script, and the tree of `Block`s to load.
	* `/drag_manager/`: Should be in the `ui` folder, let's fix that. Handles dragging blocks across the canvas and picker.
	* `/inspector_plugin/`: An inspector plugin that adds a button to the inspector on `BlockCode` nodes to open the script.
	* `/instruction_tree/`: A utility script that generates code from a tree of `TreeNode`s. This tree is created by `BlockCanvas` and also recursively by the `Block`s themselves.
	* `/lib/`: Some scripts from GodotTours that label and expose some of the editor Control nodes so they can be interfaced with.
	* `/simple_nodes/`: Contains scenes for simple nodes that can be used in a simple game. E.g. `SimpleCharacter` comes with a sprite and collision, and exposes custom movement blocks.
	* `/types/`: Contains all things related to types in the addon. Types of blocks, casting, and variant to string type conversion.
	* `/ui/`: Contains scenes and scripts for all UI related things. Block templates, `MainPanel`, etc.
		* `main_panel.tscn`: Scene for the main addon window. Holds the `Picker`, `BlockCanvas`, `DragManager`, and `TitleBar`
		* `constants.gd`: Contains various styling and functional constants for the addon.
		* `/blocks/`: Folder that holds all of the scenes for block templates.
			* `/block/`: The base class for all blocks.
			* `/statement_block/`: A block that can generate statements from multiple inputs.
			* `/parameter_block/`: A block that returns a value generated from multiple inputs.
			* `/control_block/`: A block that dictates the control flow of the program based on conditions, like if/else.
			* `/entry_block/`: A block that represents an entry point to the block script. `_ready`, `_process`, signals, etc.
			* `/utilities/`: Folder containing utilities for various blocks.
				* `/background/`: Generates a nice looking background with notches for blocks.
				* `/drag_drop_area/`: A simple node that signals on mouse down and up
				* `/parameter_input/`: An input for nodes to receive data from raw text, or from a snapped `ParameterBlock`.
				* `/snap_point/`: Node that the `DragManager` looks for when trying to snap new blocks.
		* `/block_canvas/`: Contains the code for the `BlockCanvas` which loads and holds blocks on a canvas. This can generate scripts for block scripts made for Godot `Node`s (which is all of the scripts ATM). Also contains resources for serializing blocks.
		* `/bsd_templates/`: Template block script data files for loading a default script. E.g. `_ready` and `_process` entry blocks already on canvas.
		* `/node_canvas/`: Deprecated
		* `/node_list/`: Deprecated
		* `/picker/`: Contains the picker scene, and code that generates the blocks that populate the picker.
			* `/categories/`: Contains `CategoryFactory` which generates the global block list programmatically from template blocks.
		* `/title_bar/`: Contains the title bar which should display the name of the current script and the node it inherits from.
* `/addons/gut/`: Code for Godot unit tests.
* `/addons/plugin_refresher/`: A plugin used to refresh the block_code plugin without having to turn it on and off every time.
* `/test_game/`: Contains a test game scene with example block code scripts.


