# User Documentation

## Adding Block Code to a Node

1. Open a scene, select a node, and observe that there's a **Block Code** section within the lower central pane of the Godot editor, where you usually find debugging, animation and shader functionality. Click **Block Code** and then use the **Add Block Code** button to create a block canvas.

2. Drag blocks from the picker and snap them together to create a script. You can switch to other Block Code scripts by selecting the respective node from the scene tree.

3. **Run** the scene to see your Block Code scripts in action. Block Code scripts are saved within the scene.

Block scripts run against the node where you created them. The "remove" block is going to remove that node, not any other.

The selection of available blocks varies based on the node type. For example, create a block script on an `Area2D` and you will notice that you have an `when this node collides with (something)` signal handling block available. Create a node script on an `AnimationPlayer` node and you will observe blocks for starting and stopping animations.

## Communicating Code Blocks

The "Communication" category provides blocks for this.

To communicate two nodes A and B:

1. Add Block Code to B. Add a `define method (method_name)` entry block in B. Choose a descriptive name and remember it.

2. Add Block Code to A. Add a `call method (method_name) on node (node)` and snap it where needed.

3. Still in the Block Code for A, use the single block under category "Communication | Nodes" for referencing nodes. From the dropdown, select node B.

You can also communicate with multiple nodes at the same time:

1. Add `define method (method_name)` entry block to the target nodes.

2. Add the target nodes to a group. You can do this directly from the Nodes -> Groups dock. Or you can do it dynamically using blocks `add to group (group)` and `remove from group (group)`.

3. In a Block Code, add `call method (method_name) in group (group)`.

From above, you can see that if you wish to switch context to another node, you first need to define a function in that other node, and then call it. Once execution jumps into that function, blocks will now act against that other node, and you'll have access to type-specific blocks belonging to that other node. You'll need to do this kind of thing if you want to e.g. trigger the removal of another node, or trigger an animation to start playing. This is both strong in conveying the concepts of objects and encapsulation, while also a bit tedious - we may revisit in the future!

## High Level Blocks

We have some high level blocks for simplifying common game elements.

* Add a **SimpleCharacter** node to get a game element that can be connected to keyboard and gamepad input with just one type-specific block.

* Add a **SimpleScoring** node to display a score on-screen, accompanied by simple blocks for adjusting that score.

* Add a **SimpleSpawner** node to spawn other scenes, with blocks for controlling the spawn emition and period.

* Add a **SimpleEnding** node for displaying "You win" or "Game over" in the screen with one type-specific block.

## Changing or getting any node property

Common properties like `Node2D.position` have blocks ready to be used in the picker. But (almost) any property that appears in the Inspector can be used in blocks through drag & drop:

1. Open the Block Code at the lower central pane, if not already opened.

2. In the Scene tree, select the Block Code parent node. The editor should now show its properties in the Inspector and the block canvas at the same time.

3. To access a node's property, drag the property label from the Inspector dock and drop it into the block canvas. This will create a block representing its value. You can then snap this value block into other blocks.

4. To modify the property's value, start dragging as above but press & hold Ctrl key while dropping. This will create a `set ... to (value)` block for the property.

## Referencing files in blocks

Some blocks require a file path as parameter. The `load file (file_path) as sound` is one such case. You can use drag & drop to avoid typing the file path:

1. Drag a file from the Filesystem dock and drop it into the block canvas. It will become a constant value block holding the file's resource full path.

2. Then drag the new block to the parameter slot that requires a file path.

## Other suggestions

Lean into animations! Godot's animations functionality goes beyond just simple animations of graphics. You can do so much by combining block coding with Godot's powerful animations editor.

