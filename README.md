# Godot Block Programming Plugin

This is an experimental plugin by Endless Foundation aimed at introducing Block Coding capabilities to Godot.

Our aim is to reduce the learning curve faced by learners who are on the early part of their journey towards becoming game developers. Learners within our target audience understand game concepts, but have never used Godot (or any other game engine) before, and do not have programming experience. Ordinarily, such learners are faced with the challenge of learning their way around Godot's powerful, complex editor UI, while also getting familiar with all kinds of concepts, combined with the additional challenge of learning to code for the first time as they navigate the ins and outs of GDScript.

With this project, we aim to reduce the height of the mountain that such learners have to climb. Specifically, we aim to eliminate the requirement of learners having to simultaneously learn to code while building their first games. Instead of writing GDScript to implement games, this plugin lets learners use block coding. Tools like Scratch and Makecode have demonstrated that block coding can be much more accessible and intuitive to beginners than textual programming.

In order to be learner-friendly, we have to implement blocks at a suitable level of abstraction. For example in GDScript you would typically move a sprite around the screen by examining input events and adjusting a sprite's movement vector accordingly, but we do not wish to express this level of detail in blocks. Instead, we lean much more towards the kinds of blocks you can find in Makecode Arcade, such as having a single block for "move mySprite with buttons".

Expressing an appropriate layer of abstraction is perhaps the most challenging aspect of this project, and will likely place limits upon what can be achieved with this tool. We do not aim to express the full power of Godot & GDScript with this block coding plugin, but rather, our objective is to provide a gentler introduction to Godot for learners, such that they can get familiar with other aspects of the Godot Editor and learn programming concepts while creating basic games. We envision that learners would use block coding as a stepping stone and then later progress onto learning GDScript.

That said, we are in no way opposed to having this project grow to be able to create more complex games, as long as it does not negatively affect the experience for learners.

# Current status

We are nearing our initial milestone where simple games can be created with blocks. This is a kind of MVP demo which will then let us figure out our next steps.

Despite having an initial implementation we have many questions open for reconsideration including:
- Have we created a learner-friendy abstraction that is suitably aligned with Godot concepts?
- What is the most appropriate way to attach block scripts to a project?
- Should this be a plugin or an extension?
- Should blocks generate GDScript or be dynamically executed?
- etc.

# Development

## pre-commit

Please use [pre-commit](https://pre-commit.com/) to check for correct formatting and other issues before creating commits. To do this automatically, you can add it as a git hook:

```
# If you don't have pre-commit already:
pip install pre-commit

# Setup git hook:
pre-commit install
```

Now `pre-commit` will run automatically on `git commit`!
