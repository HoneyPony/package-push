extends "res://PuzzleEntity.gd"

func amod(a, b):
	var f = fmod(a, b)
	if a < 0:
		return fmod(f + b, b)
	return f

func fract(f):
	return amod(f, 1)
		
func constant_rand(co: Vector2):
	return fract(sin(co.dot(Vector2(12.9898,78.233)))) * 43758.5453

func update_tex():
	var r = amod(constant_rand(position), 4.0)
	if r < 1.0:
		pass
	elif r < 2.0:
		$Sprite.texture = load("res://vector/Package2.svg")
	elif r < 3.0:
		$Sprite.texture = load("res://vector/Package3.svg")
	else:
		$Sprite.texture = load("res://vector/Package4.svg")
	

func is_package():
	return true
