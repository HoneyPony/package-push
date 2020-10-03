extends "res://PuzzleEntity.gd"

onready var anim = $AnimationPlayer
onready var Foam = load("res://Foam.tscn")

enum Dir {
	Left,
	Right,
	Up,
	Down
}

enum Ins {
	Forward,
	Left,
	Right,
	Foam
}

var direction = Dir.Down

func _ready():
	instructions = [Ins.Foam, Ins.Forward, Ins.Left]

func is_movable():
	return false
	
func get_target_direction():
	if direction == Dir.Down:
		return 0
	if direction == Dir.Right:
		return 270
	if direction == Dir.Up:
		return 180
	if direction == Dir.Left:
		return 90
	
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
		return

	if i == Ins.Forward:
		if direction == Dir.Right:
			grid.move_object_right(grid_x, grid_y)
		elif direction == Dir.Left:
			grid.move_object_left(grid_x, grid_y)
		elif direction == Dir.Up:
			grid.move_object_up(grid_x, grid_y)
		elif direction == Dir.Down:
			grid.move_object_down(grid_x, grid_y)
		
	if i == Ins.Left:
		rotate_left()
		
	if i == Ins.Right:
		rotate_right()
		
	if i == Ins.Foam:
		var x = grid_x
		var y = grid_y
		
		if direction == Dir.Left:
			x -= 1
		if direction == Dir.Right:
			x += 1
		if direction == Dir.Down:
			y += 1
		if direction == Dir.Up:
			y -= 1
			
		if grid.is_air(x, y):
			var foam = Foam.instance()
			foam.grid_x = x
			foam.grid_y = y
			foam.position = $Sprite2/FoamSource.global_position + Vector2(-32, -32)
			foam.initial_target = Vector2(x * 64, y * 64)
			get_parent().call_deferred("add_child", foam)
			
			grid.set_grid_ref(x, y, foam)

func _process(delta):
	var dir = $Sprite2.rotation_degrees
	var tar = get_target_direction()
	
	var dif = tar - dir
	dif = fmod(dif, 360)
	
	if abs(dif) > 180:
		dif = (sign(dif) * 180) - dif
	
	$Sprite2.rotation_degrees += dif * 0.2
