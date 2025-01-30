# Technical Overview

## How to create a new block

Blocks can be created by adding a `BlockDefinition` resource. The global blocks live in resource files under `addons/block_code/blocks/` and are organized in folders by category. You can edit these files in the Godot editor directly, by opening them from the Filesystem Dock. As any other Godot resource, they show up in the Inspector. You can use current ones as reference.

Currently, blocks for custom nodes can't be defined in the same way. They are instead defined programmatically in their GDScript by adding two functions: `func get_custom_class()` and `static func setup_custom_blocks()`. This is expected to be fixed in the future. See the "Simple" nodes provided by this plugin for reference. For example, `addons/block_code/simple_nodes/simple_character/simple_character.gd`.

You don't have to worry for adding blocks for properties setter, getter or "changer". These are generated dynamically in `addons/block_code/code_generation/blocks_catalog.gd`.

## User Interface

The plugin adds a new tab "Block Code" to the editor bottom dock. This contains the `MainPanel` control scene. Which has the following elements:
	* The `Picker`: Contains the list of blocks organized in categories.
	* The `BlockCanvas`: Is where placed blocks live. It edits the `BlockScriptSerialization` that generates the code.
	* The `TitleBar`: Has a dropdown to switch the BlockCode being edited and other controls.
	* The `DragManager`: Determines how blocks are snapped, and what happens when you drag a block from either the `Picker` or the `BlockCanvas`.

The `DragManager` looks for the closest compatible snap point within a certain range, and if it exists, will show a preview where your `Block` will go if you drop it.
	* Each `Block` has a `block_type` property, and so does each snap point. They must match to snap.
	* If a `Block` has the block type `VALUE`, it should have a `variant_type` property (since it represents a value). In that case, it's `variant_type` is considered for snapping along with the snap point's `variant_type`.

The `Block` UI is a regular Godot scene. There is one per each `block_type`. One current discrepancy is that the UI for the `VALUE` block type is called `ParameterBlock`. All others match: eg. for the `CONTROL` type there is a `ControlBlock` scene.

The `BlockCanvas` is filled with blocks as defined in the `BlockScriptSerialization`. When the user interacts with the `BlockCanvas`, the `BlockScriptSerialization` regenerates its GDScript. For instance when the user attaches blocks, or changes the block text input or dropdowns (scene instances of `ParameterInput`).

