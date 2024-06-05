class_name my_character
extends SimpleCharacter

func _ready():
	pass

func _process(_delta):
	velocity = Input.get_vector("Left", "Right", "Up", "Down")*500
	move_and_slide()

