# Block Programming Plugin

This is a work in progress editor plugin that generates code from blocks in Godot.

The entry point of the addon is in `addons/block_code.gd` which adds a `MainPanel` instance as a main screen tab (titled "Block Code").

## WIP

- [x] Support should be added for blocks that have two inner blocks (e.g. if/else statements)

- [ ] Blocks should also be able to be inserted, not just appended.

### Block script editor UI

- [ ] Make it so that the script editor doesn't also open the generated script when block script is opened

- [ ] Fix block script editor not opening after first press

- [ ] Stop dialog box from opening when script reloaded

## pre-commit

Please use [pre-commit](https://pre-commit.com/) to check for correct formatting and other issues before creating commits. To do this automatically, you can add it as a git hook:

```
# If you don't have pre-commit already:
pip install pre-commit

# Setup git hook:
pre-commit install
```

Now `pre-commit` will run automatically on `git commit`!
