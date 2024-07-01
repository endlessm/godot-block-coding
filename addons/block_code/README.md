# Godot Block Coding Plugin

Experimental plugin by [Endless OS Foundation](https://endlessos.org) that introduces a high-level, block-based visual programming language as an educational tool.

[![Godot asset](https://img.shields.io/badge/Asset_Library-Block_Coding-blue?logo=godot-engine)](https://godotengine.org/asset-library/asset/3095)
[![Latest release](https://img.shields.io/github/v/release/endlessm/godot-block-coding?label=Release&logo=github)](https://github.com/endlessm/godot-block-coding/releases)

## Background

Our aim is to reduce the learning curve faced by learners who are on the early part of their journey towards becoming game developers. Learners within our target audience understand game concepts, but have never used Godot (or any other game engine) before, and do not have programming experience. Ordinarily, such learners are faced with the challenge of learning their way around Godot's powerful, complex editor UI, combined with the additional challenge of learning to code for the first time as they navigate the ins and outs of GDScript.

With this project, we aim to reduce the height of the mountain that such learners have to climb. Specifically, we aim to eliminate the requirement of learners having to simultaneously learn to code while building their first games. Instead of writing GDScript to implement games, this plugin enables learners use block coding. Tools like [Scratch](https://scratch.mit.edu/), [Blockly](https://developers.google.com/blockly), and [MakeCode](https://www.microsoft.com/en-us/makecode) have demonstrated that block coding can be much more accessible and intuitive to beginners than textual programming—we are bringing those concepts into Godot to help learners become familiar with some aspects of Godot itself while simplifying the creation of their first games.

### Constraints

In order to be learner-friendly, we have to implement blocks at a suitable level of abstraction. For example, in GDScript you would typically move a sprite around the screen by examining input events and adjusting a sprite's movement vector accordingly—but we do not wish to express this level of detail in blocks. Instead, we lean much more towards the kinds of blocks you can find in MakeCode Arcade, such as having a single block for "move mySprite with buttons".

Expressing an appropriate layer of abstraction is perhaps the most challenging aspect of this project, and will likely place limits upon what can be achieved with this tool. We do not aim to express the full power of Godot & GDScript with this block coding plugin, but rather, our objective is to provide a gentler introduction to Godot for learners, such that they can get familiar with other aspects of the Godot Editor and learn programming concepts while creating basic games. We envision that learners would use block coding as a stepping stone and then later progress onto learning GDScript.

That said, we are in no way opposed to having this project grow to be able to create more complex games, as long as it does not negatively affect the experience for early stage learners.

## Getting Started

1. Install the plugin through the Godot AssetLib searching for the name
   Block Coding. You can also download it from the online [Asset
   Library](https://godotengine.org/asset-library/asset/3095) and import
   it through AssetLib. Alternatively, you can clone the git repository and
   drag the `addons/block_code/` directory into your project's
   `res://addons/` directory. *If you want to open the cloned repository
   project, reload the project once after opening it for the first time
   to resolve any errors. This is a Godot issue.*

2. Make sure to enable the plugin in **Project** → **Project Settings** → **Plugins**.

3. You're ready to get started! Open a scene, and add a **BlockCode** child node to any node in the scene using the **Add Child Node** menu dialog.

4. The **Block Code** editor will open in a new tab. Drag blocks from the picker and snap them together to create a script. You can switch to other Block Code scripts by selecting the respective BlockCode node in the scene tree.

5. **Run** the scene to see your Block Code scripts in action. Block Code scripts are attached to the BlockCode node's parent, and are saved to the scene.

If you clone the plugin's git repository and open it in Godot, you will be presented with a block-built Pong game as an example.

## Current Status

Basic games can be created with this early prototype, but there is plenty of work ahead.

We will now seek feedback from learners, educators and game makers, as well as revisit some of the technical architecture decisions. Open questions include:
- Have we created a learner-friendy abstraction that is suitably aligned with Godot concepts?
- What is the most appropriate way to attach block scripts to a project?
- Should this be a plugin or an extension?
- Should blocks generate GDScript or be dynamically executed?

## Feedback

Please share feedback in the [Godot Forum Block Coding thread](https://forum.godotengine.org/t/block-coding-high-level-block-based-visual-programming/68941).

## Development

### pre-commit

Please use [pre-commit](https://pre-commit.com/) to check for correct formatting and other issues before creating commits. To do this automatically, you can add it as a git hook:

```shell
# If you don't have pre-commit already:
pip install pre-commit

# Setup git hook:
pre-commit install
```

Now `pre-commit` will run automatically on `git commit`!

### Testing

This plugin uses the [Godot Unit Test](https://gut.readthedocs.io/en/latest/) (GUT) plugin for testing. In the editor, select the **GUT** tab in the bottom panel to open the test panel. Then select **Run All** to run the tests.

Tests can also be run from the command line using the GUT command line script:

```
godot --path . --headless --script addons/gut/gut_cmdln.gd -gexit
```

A few options are of note here. `--path` instructs Godot to use the project in
the current directory. `--headless` instructs Godot to run without a display or
sound. `--script` instructs Godot to run the GUT command line script instead of
running the main scene. `-gexit` is an option for the GUT command line script
that instructs GUT to exit after the tests complete.

There are several other GUT command line options for running specific tests.
For example, `-gtest=path/to/test_script_1.gd,path/to/test_script_2.gd` can be
used to run specific test scripts. A specific test function can be specified
with `-gunit_test_name=test_to_run`.
