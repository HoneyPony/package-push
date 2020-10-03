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
	Backward,
	Left,
	Right,
	Foam,
	Spin
}

var direction = Dir.Right

func _ready():
	instructions = []

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
		
	return 270
	
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
			
	if i == Ins.Backward:
		if direction == Dir.Left:
			grid.move_object_right(grid_x, grid_y)
		elif direction == Dir.Right:
			grid.move_object_left(grid_x, grid_y)
		elif direction == Dir.Down:
			grid.move_object_up(grid_x, grid_y)
		elif direction == Dir.Up:
			grid.move_object_down(grid_x, grid_y)
		
	if i == Ins.Left:
		rotate_left()
		
	if i == Ins.Right:
		rotate_right()
		
	if i == Ins.Spin:
		rotate_right()
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
			
func set_dir_instant():
	$Sprite2.rotation_degrees = fmod(get_target_direction(), 360)

func _process(delta):
	var dir = $Sprite2.rotation_degrees
	var tar = get_target_direction()
	
	var dif = tar - dir
	dif = fmod(dif, 360)
	
	if abs(dif) > 180:
		dif = (sign(dif) * 180) - dif
	
	var final_tar = dir + dif
	var now_sign = sign($Sprite2.rotation_degrees - final_tar)
	
	$Sprite2.rotation_degrees += 900 * delta * sign(dif)
	
	if sign($Sprite2.rotation_degrees - final_tar) != now_sign:
		$Sprite2.rotation_degrees = final_tar
		$Sprite2.rotation_degrees = fmod($Sprite2.rotation_degrees, 360)
		
	if abs($Sprite2.rotation_degrees - final_tar) < 900 * delta * 2:
		$Sprite2.rotation_degrees = final_tar
		$Sprite2.rotation_degrees = fmod($Sprite2.rotation_degrees, 360)
