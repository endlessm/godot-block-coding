# Audience, objectives and pedagogy

This document aims to outline the motivation for the creation of the block
coding plugin, the intended audience, design goals and non-goals.

Note that the design, the pedagogy, and the tool itself are all under
evolution. This document aims to describe the direction we see ourselves
going in; the actual tool itself may be a bit 'behind' in the implementation
of these principles.

## Overall motivation

We want to engage the largest possible audience in game creation, with a
particular focus on young and underserved audiences. We aim to grow the game
creation spark in those that didn't know they had it, and help aspiring
game creators step towards becoming expert users of the Godot engine.

Learners on this journey must face a tremendous learning curve. Godot is
very powerful, and it is also complex. Learners within these groups face
numerous challenges in order to become proficient at Godot, and within those,
the most significant challenge is the need to learn GDScript, which is
often their first exposure to computer programming.

The block coding plugin aims to make game creation in Godot much easier
to achieve for those learners, by postponing or eliminating the need to learn
computer programming & GDScript. Those learners can first focus their
attention on learning their way around the Godot editor, node types,
inspector properties, animations, etc. without the simultaneous additional
burden of having to learn programming.

## Learning tool

This plugin is intended to be used as a learning tool. The intended audience
consists of aspiring game creators that are getting started in Godot, and
have limited or no computer programming experience.

Block coding is not intended to be a replacement for GDScript. We anticipate
that there will things that are infeasible to achieve with block programming,
but perfectly possible with GDScript or other advanced programming tools.

We anticipate that once learners have found their bearings in Godot, if they
have enough curiosity and motivation for the coding aspect they will then
progress to learn GDScript and abandon block coding.

That said, we are not against receiving contributions that increase the
scope of what can be achieved with block programming, as long as that
does not detract from the learner experience within our primary audience.


## A layer on top of Godot

We offer block coding as a layer on top of Godot. It does not intend to
deviate far from the typical foundations of 'ordinary' Godot game building.
In order to build games with blocks, you need to understand nodes and scenes,
you need to use the inspector, build tilemaps, etc. The block coding aspect
is aimed to be complementary, we will not attempt to (e.g.) offer an
animation-building block language (we expect the user to learn and
use Godot's standard animation functionality).

This is somewhat contrary to some other block coding environments. Scratch,
for example, seeks primarily to be a highly effective digital creation tool
that embodies the principles of constructionism. As such, they have features
and behaviours that are not feasible or interesting for our tool, e.g.
in Scratch everything is a sprite (there is no hierarchy or typing, every
block works on every sprite), and blocks are live e.g. the program is
constantly running in some sense, you can click on blocks to instantly see
what they do. These features are inherent to Scratch's focus on being the
most powerful digital creation tool around, whereas our block coding
language's inherent focus is on top of the existing norms of the Godot engine.

## Teach Godot concepts, but with natural language

Learners who succeed in using our tool to build games will become familiar
with the concepts of game building with Godot & GDScript, however we prefer
to use natural language for the text on the blocks themselves (e.g. "when
another node collides with this one") rather than Godot's technical terms
(e.g. "on body entered").

We believe the use of natural language provides a much smoother learning
experience, and that if learners later progress to GDScript, they will be
immediately and effortlessly able to recognise that the syntax to do X was
worded as Y in the block language. The important thing is that they have
picked up the underlying concepts through building games with blocks.

## Focus on high level abstraction

Our block language does not intend to mirror GDScript. Instead, we focus on
providing a higher level of abstraction. There's so much value in having
learners being able to very quickly drag and drop just a few blocks and have
a working game. It makes building simple games that much smoother. We want to
trigger a "holy cow, I can actually do this" spark in our learners after just
a few minutes, which will provide the motiviational drive for them to persist
along the challenging journey of mastering Godot.

Compared to GDScript, there are also some things that are just tedious and
boring to do in regular blocks, like displaying a score counter on the
screen. Try creating block code to maintain a score variable which you then
convert to text, embed in a label and show on-screen, it's a bit annoying how
many blocks are involved in that simple operation. So we provide higher level
components that make common things like this dead simple.

Despite our desire to provide fun, easy high level blocks, we do not exclude
the provision of lower level blocks as a secondary goal. For example, we
provide a single ultra simple high-level block that lets you move a sprite
around based on arrow key input, which is heavily inspired by Makecode Arcade's
"move mySprite with buttons" block. However if you wish to calculate a
sprite's movement vector based on keyboard input, and then ask the physics
engine to move things around (as you'd typically do in GDScript), then we have
blocks that let you do that.

## Limited scope of game genres & functionality

Through our focus on learner-suitable high level abstraction instead of
mirroring GDScript, we hit the tradeoff that some capabilities are lost,
you may encounter things that you can't implement in blocks.

We're focused on facilitating creation of 2D games, particularly platformers
and top-down games. We'll try to plug obvious gaps in the block collection and
capabilities as we find them.

We're open to contributions that increase the scope of what can be created
with blocks, as long as it doesn't compromise the learner experience on
those 2D game genres.

## Code generation is not a goal

Internally, our plugin converts block scripts created by the user into
real GDScript. There's a button that lets you see the GDScript code generated
by your blocks.

We regard the code generation as an internal implementation detail that might
go away in future. It is done this way because it was the fastest way to
prototype the block language back when we started the project, and we haven't
yet encountered strong reasons to change it. But we might.

It's nice to think that this functionality could have some value to learners
who later progress onto GDScript. If they can build in blocks and then see
the equivalent GDScript, isn't that going to facilitate the transition?

While there's undoubtedly a little value in that, in reality it is not
as useful as it sounds. A learner's programming journey typically begins
with very trivial programs or carefully orchestrated small code changes, to
avoid being overwhelmed by a larger body of work. Learners benefit most from
high quality, well crafted and nicely formatted code, with associated
documentation and guidance. The internal output of our block coding plugin
does not attempt to provide any of those; we wouldn't advocate showing it
to learners who have never seen code before.

