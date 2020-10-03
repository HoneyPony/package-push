extends "res://PuzzleEntity.gd"

onready var anim = $AnimationPlayer

enum Dir {
	Left,
	Right,
	Up,
	Down
}

enum Ins {
	Forward,
	Left,
	Right
}

var direction = Dir.Right

func _ready():
	instructions = [Ins.Forward, Ins.Forward, Ins.Left]

func is_movable():
	return false
	
func anim_idle():
	if direction == Dir.Right:
		anim.play("RightIdle")
	if direction == Dir.Left:
		anim.play("LeftIdle")
	if direction == Dir.Up:
		anim.play("UpIdle")
	if direction == Dir.Down:
		anim.play("DownIdle")
	
func rotate_left():
	if direction == Dir.Right:
		direction = Dir.Up
	elif direction == Dir.Up:
		direction = Dir.Left
	elif direction == Dir.Left:
		direction = Dir.Down
	else:
		direction = Dir.Right
		
func rotate_right():
	if direction == Dir.Right:
		direction = Dir.Down
	elif direction == Dir.Down:
		direction = Dir.Left
	elif direction == Dir.Left:
		direction = Dir.Up
	else:
		direction = Dir.Right
	
func handle_instruction(i, grid):
	if i == null:
		anim_idle()
		return

	if i == Ins.Forward:
		if direction == Dir.Right:
			grid.move_object_right(grid_x, grid_y)
			anim.play("RightIdle")
		elif direction == Dir.Left:
			grid.move_object_left(grid_x, grid_y)
			anim.play("LeftIdle")
		elif direction == Dir.Up:
			grid.move_object_up(grid_x, grid_y)
			anim.play("UpIdle")
		elif direction == Dir.Down:
			grid.move_object_down(grid_x, grid_y)
			anim.play("DownIdle")
		
	if i == Ins.Left:
		rotate_left()
		anim_idle()
		
	if i == Ins.Right:
		rotate_right()
		anim_idle()

func _process(delta):
	if direction == Dir.Left:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
		
	if direction == Dir.Down:
		$Sprite.flip_v = true
	else:
		$Sprite.flip_v = false
		
	if direction == Dir.Down or direction == Dir.Up:
		$Sprite.frame = 1
	else:
		$Sprite.frame = 0
