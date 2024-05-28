# Block Programming Plugin

This is a work in progress editor plugin that generates code from blocks in Godot.

The entry point of the addon is in `addons/block_code.gd` which adds a `MainPanel` instance as a main screen tab (titled "Block Code").

So far the `MainPanel` window has a `Picker` and `BlockCanvas` positioned side by side so you can pick blocks from the `Picker` and drag them into the `BlockCanvas`

As a simple test, you can press the `f` key which will trigger a function call in the `MainPanel` node that generates a script based on the nodes on the screen.

At the moment there are only two nodes, a for loop and basic print block, but it is easy to create custom nodes with snap points/inner children.


## WIP

Support should be added for blocks that have two inner blocks (e.g. if/else statements), and blocks should also be able to be inserted, not just appended.

## pre-commit

Please use [pre-commit](https://pre-commit.com/) to check for correct formatting and other issues before creating commits. To do this automatically, you can add it as a git hook:

```
# If you don't have pre-commit already:
pip install pre-commit

# Setup git hook:
pre-commit install
```

Now `pre-commit` will run automatically on `git commit`!