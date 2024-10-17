extends Object

const CURRENT_DATA_VERSION = 0

const KNOB_X = 10.0
const KNOB_W = 20.0
const KNOB_H = 5.0
const KNOB_Z = 5.0
const CONTROL_MARGIN = 20.0
const OUTLINE_WIDTH = 3.0
const MINIMUM_SNAP_DISTANCE = 80.0
const MINIMUM_DRAG_THRESHOLD = 25

const FOCUS_BORDER_COLOR = Color(225, 242, 0)

## Properties for builtin categories. Order starts at 10 for the first
## category and then are separated by 10 to allow custom categories to
## be easily placed between builtin categories.
const BUILTIN_CATEGORIES_PROPS: Dictionary = {
	"Lifecycle":
	{
		"color": Color("ec3b59"),
		"order": 10,
		"icon": "PlayStart",
	},
	"Lifecycle | Spawn":
	{
		"color": Color("ec3b59"),
		"order": 15,
		"icon": "Play",
	},
	"Transform | Position":
	{
		"color": Color("4b6584"),
		"order": 20,
		"icon": "ToolMove",
	},
	"Transform | Rotation":
	{
		"color": Color("4b6584"),
		"order": 30,
		"icon": "ToolMove",
	},
	"Transform | Scale":
	{
		"color": Color("4b6584"),
		"order": 40,
		"icon": "ToolMove",
	},
	"Graphics | Modulate":
	{
		"color": Color("03aa74"),
		"order": 50,
		"icon": "Paint",
	},
	"Graphics | Visibility":
	{
		"color": Color("03aa74"),
		"order": 60,
		"icon": "Paint",
	},
	"Graphics | Viewport":
	{
		"color": Color("03aa74"),
		"order": 61,
		"icon": "Paint",
	},
	"Graphics | Animation":
	{
		"color": Color("03aa74"),
		"order": 62,
		"icon": "Paint",
	},
	"UI":
	{
		"color": Color("03aa74"),
		"order": 65,
		"icon": "ThemeDeselectAll",
	},
	"Sounds":
	{
		"color": Color("e30fc0"),
		"order": 70,
		"icon": "AudioStreamPlayer",
	},
	"Physics | Mass":
	{
		"color": Color("a5b1c2"),
		"order": 80,
		"icon": "RigidBody2D",
	},
	"Physics | Velocity":
	{
		"color": Color("a5b1c2"),
		"order": 90,
		"icon": "RigidBody2D",
	},
	"Input":
	{
		"color": Color("d54322"),
		"order": 100,
		"icon": "Slot",
	},
	"Communication | Methods":
	{
		"color": Color("4b7bec"),
		"order": 110,
		"icon": "Signals",
	},
	"Communication | Nodes":
	{
		"color": Color("4b7bec"),
		"order": 115,
		"icon": "Signals",
	},
	"Communication | Groups":
	{
		"color": Color("4b7bec"),
		"order": 120,
		"icon": "Signals",
	},
	"Info | Score":
	{
		"color": Color("cf6a87"),
		"order": 130,
		"icon": "NodeInfo",
	},
	"Loops":
	{
		"color": Color("20bf6b"),
		"order": 140,
		"icon": "RotateRight",
	},
	"Logic | Conditionals":
	{
		"color": Color("45aaf2"),
		"order": 150,
		"icon": "AnimationFilter",
	},
	"Logic | Comparison":
	{
		"color": Color("45aaf2"),
		"order": 160,
		"icon": "AnimationFilter",
	},
	"Logic | Boolean":
	{
		"color": Color("45aaf2"),
		"order": 170,
		"icon": "AnimationFilter",
	},
	"Variables":
	{
		"color": Color("ff8f08"),
		"order": 180,
		"icon": "Key",
	},
	"Math":
	{
		"color": Color("a55eea"),
		"order": 190,
		"icon": "VisualShaderNodeVectorFunc",
	},
	"Log":
	{
		"color": Color("002050"),
		"order": 200,
		"icon": "Debug",
	},
}
