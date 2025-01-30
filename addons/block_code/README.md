# Godot Block Coding Plugin

Experimental plugin by [Endless OS Foundation](https://endlessos.org) that introduces a high-level, block-based visual programming language as an educational tool.

[![Godot asset](https://img.shields.io/badge/Asset_Library-Block_Coding-blue?logo=godot-engine)](https://godotengine.org/asset-library/asset/3095)
[![Latest release](https://img.shields.io/github/v/release/endlessm/godot-block-coding?label=Release&logo=github)](https://github.com/endlessm/godot-block-coding/releases)

[![Youtube video](https://i.ibb.co/B2Y11n5/Bildschirmfoto-20241213-173815.png)](https://www.youtube.com/watch?v=WlUN7Zz0Djg)

## Background

Our aim is to reduce the learning curve faced by learners who are on the early part of their journey towards becoming game developers. Learners within our target audience understand game concepts, but have never used Godot (or any other game engine) before, and do not have programming experience. Ordinarily, such learners are faced with the challenge of learning their way around Godot's powerful, complex editor UI, combined with the additional challenge of learning to code for the first time as they navigate the ins and outs of GDScript.

With this project, we aim to reduce the height of the mountain that such learners have to climb. Specifically, we aim to eliminate the requirement of learners having to simultaneously learn to code while building their first games. Instead of writing GDScript to implement games, this plugin enables learners use block coding. Tools like [Scratch](https://scratch.mit.edu/), [Blockly](https://developers.google.com/blockly), and [MakeCode](https://www.microsoft.com/en-us/makecode) have demonstrated that block coding can be much more accessible and intuitive to beginners than textual programming—we are bringing those concepts into Godot to help learners become familiar with some aspects of Godot itself while simplifying the creation of their first games.

In order to be learner-friendly, we implement blocks at a suitable level of abstraction. For example, we have blocks that allow the user to trivially connect keyboard and gamepad input to the movement of a particular game element, and to make the score show up on-screen. That abstraction does place limits on what can be achieved with this tool, while still allowing us to provide a gentler introduction to Godot for learners, such that they can get familiar with other aspects of the Godot Editor and learn programming concepts while creating basic games. We envision that learners would use block coding as a stepping stone and then later progress onto learning GDScript.

That said, we are in no way opposed to having this project grow to be able to create more complex games, as long as it does not negatively affect the experience for early stage learners.

See our [pedagogy and audience documentation](docs/PEDAGOGY.md) for more info.

## Getting Started

1. Make sure you have Godot 4.3 or a newer version installed.

2. Install the plugin through the Godot AssetLib searching for the name
   Block Coding. You can also download it from the online [Asset
   Library](https://godotengine.org/asset-library/asset/3095) and import
   it through AssetLib. Alternatively, you can clone the git repository and
   drag the `addons/block_code/` directory into your project's
   `res://addons/` directory. *If you want to open the cloned repository
   project, reload the project once after opening it for the first time
   to resolve any errors. This is a Godot issue.*

3. Make sure to enable the plugin in **Project** → **Project Settings** → **Plugins**.

You're ready to get started! You can continue reading our [user documentation](docs/USAGE.md).

If you clone the plugin's git repository and open it in Godot, you will be presented with a block-built Pong game as an example.

## Current Status

Basic games can be created with this early prototype, but there is plenty of work ahead.

We will now seek feedback from learners, educators and game makers, as well as revisit some of the technical architecture decisions. Open questions include:
- Have we created a learner-friendy abstraction that is suitably aligned with Godot concepts?
- What is the most appropriate way to attach block scripts to a project?
- Should this be a plugin or an extension?
- Should blocks generate GDScript or be dynamically executed?

There is no language or data format stability implemented or expected in these early stages. If you upgrade the block coding plugin within an existing project, expect any existing block scripts to stop working and need reimplementing from scratch. For now, you probably want to avoid updating the plugin within your project if it's meeting your needs, or only doing that very sporadically. We will consider offering stability guarantees in future stages of development.

## Feedback & Discussion

Please join our [Discussion Board](https://github.com/endlessm/godot-block-coding/discussions) to provide feedback, share ideas, and ask questions about building your games with Block Coding.

## Localization

The plugin supports translations through Godot's [gettext][godot-gettext]
support. We welcome contributions to make the plugin work better in your
language! However, please note that translations in the Godot editor **will
only work with Godot 4.4 or newer**.

The gettext PO files are located in the `addons/block_code/locale` directory.
See the Godot [documentation][godot-gettext] for instructions on working with
PO files. You can also join our project on [Transifex][transifex-project] to
collaborate with others translating the Block Coding content.

[godot-gettext]: https://docs.godotengine.org/en/stable/tutorials/i18n/localization_using_gettext.html
[transifex-project]: https://explore.transifex.com/endless-os/godot-block-coding/

For developers, a few things need to be done to keep the translatable strings
up to date.

* If files are added or removed, the list of translatable files needs to be
  updated. This can be done by using the **Add** dialog in the [POT
  Generation][pot-generation] tab. Or you can use the **Project → Tools →
  Update BlockCode translated files** menu item in the editor. From the command
  line, the POT file can be regenerated with the `scripts/update-pot-files.sh`
  shell script.

* If translatable strings have changed, the POT file needs to be updated. This
  can be done by using the **Generate POT** dialog in the [POT
  Generation][pot-generation] tab. Or you can use the **Project → Tools →
  Regenerate BlockCode POT file** menu item in the editor. From the command
  line, the POT file can be regenerated with the `scripts/regenerate-pot.sh`
  shell script.

* If the POT file has changed, the PO message files need to be updated. This
  can be done using the gettext `msgmerge` tool with the
  `scripts/merge-messages.sh` shell script.

[pot-generation]: https://docs.godotengine.org/en/stable/tutorials/i18n/localization_using_gettext.html#automatic-generation-using-the-editor

Strings added in scene files or block definition resources will usually be
extracted for localization and translated in the editor automatically. Strings
in scripts need more consideration.

* `Object`s or `Node`s that are not descendents of the Block Coding panel need
  to have their translation domain set with the `set_block_translation_domain`
  helper function. This should usually be done in the object's `_init` method
  to make sure the translation domain is set before that object or any of its
  descendents (which inherit the translation domain by default) try to use
  localized strings.

* Usually [`tr`][object-tr] and [`tr_n`][object-tr-n] (or [`atr`][node-atr] and
  [`atr_n`][node-atr-n] for `Node`s) should be used to mark translatable
  strings. These will eventually call the domain's
  [`translate`][domain-translate] or
  [`translate_plural`][domain-translate-plural] methods, but the `tr` methods
  respect translation settings on the object instances. The only time the
  `translate` methods should be called directly is within a static context when
  an object instance isn't available.

[object-tr]: https://docs.godotengine.org/en/stable/classes/class_object.html#class-object-method-tr
[object-tr-n]: https://docs.godotengine.org/en/stable/classes/class_object.html#class-object-method-tr-n
[node-atr]: https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-atr
[node-atr-n]: https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-atr-n
[domain-translate]: https://docs.godotengine.org/en/latest/classes/class_translationdomain.html#class-translationdomain-method-translate
[domain-translate-plural]: https://docs.godotengine.org/en/latest/classes/class_translationdomain.html#class-translationdomain-method-translate-plural

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
godot --path . --headless -s addons/gut/gut_cmdln.gd -gexit
```

A few options are of note here:

- `--path` instructs Godot to use the project in the current directory.
- `--headless` instructs Godot to run without a display or sound.
- `-s` instructs Godot to run the GUT command line script instead of
  running the main scene. Due to a [bug in
  GUT](https://github.com/bitwes/Gut/issues/667), the long form `--script`
  cannot be used.
- `-gexit` is an option for the GUT command line script that instructs GUT to
  exit after the tests complete.

There are several other GUT command line options for running specific tests.
For example, `-gtest=path/to/test_script_1.gd,path/to/test_script_2.gd` can be
used to run specific test scripts. A specific test function can be specified
with `-gunit_test_name=test_to_run`.

### Using the Development Version of the Plugin

1. If your project already has the BlockCode plugin installed:
    1. Ensure you have committed your project to Git, including the `addons/block_code` directory.
       At this stage of development, **block code programs written for an older plugin version will
       likely not work with a newer version of the plugin**, so it is essential that you take a
       snapshot of your project before changing the plugin version.
    2. Under *Project* → *Project Settings…* → *Plugins*, disable the BlockCode plugin
    3. In the *FileSystem* sidebar, delete the `res://addons/block_code` directory
2. Download
   [a development snapshot](https://github.com/endlessm/godot-block-coding/archive/main.zip)
3. Under *AssetLib*, click *Import…*, and browse to the `main.zip` file you just downloaded
4. Check the *☑ Ignore assert root* option, and click *Install*
5. Under *Project* → *Project Settings…* → *Plugins*, enable the BlockCode plugin
