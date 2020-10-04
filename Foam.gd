extends "res://PuzzleEntity.gd"

var initial_target = null

func _ready():
	override_puzzle_entity = true
	
	var tex = floor(rand_range(0, 2.95))
	if tex == 1:
		$Sprite.texture = load("res://vector/CreateFoam2.png")
	elif tex == 2:
		$Sprite.texture = load("res://vector/CreateFoam3.png")

func _process(delta):
	if speed.length() > 0:
		initial_target = null
		override_puzzle_entity = false

	if initial_target != null:
		position += (initial_target - position) * 0.3

		if (position - initial_target).length_squared() < 1:
			position = initial_target
			initial_target = null
			override_puzzle_entity = false

	
