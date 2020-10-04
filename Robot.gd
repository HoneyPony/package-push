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

var which_robot = 0
var coordinator = null

onready var t1 = get_node("Sprite2/Sprite2/Tread/AnimationPlayer")
onready var t2 = get_node("Sprite2/Sprite2/Tread2/AnimationPlayer")

onready var pupil = get_node("Sprite2/Sprite2/Sprite")
var pupil_rot_target = 180
var pupil_timer = 1.5

func handle_pupil(delta):
	pupil.rotation_degrees += (pupil_rot_target - pupil.rotation_degrees) * 0.2
	
	pupil_timer -= delta
	if pupil_timer <= 0:
		pupil_timer = rand_range(0.8, 2.1)
		pupil.rotation_degrees = fmod(pupil.rotation_degrees, 360.0)
		pupil_rot_target = pupil.rotation_degrees + rand_range(-90, 90) + rand_range(-90, 90)

func update_texture(coord):
	var tex_name = "res://vector/Nums/Num" + String(which_robot) + ".svg"
	
	$Number.texture = load(tex_name)
	coordinator = coord

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
		var gx = grid_x
		var gy = grid_y
		
		if direction == Dir.Right:
			grid.move_object_right(grid_x, grid_y)
		elif direction == Dir.Left:
			grid.move_object_left(grid_x, grid_y)
		elif direction == Dir.Up:
			grid.move_object_up(grid_x, grid_y)
		elif direction == Dir.Down:
			grid.move_object_down(grid_x, grid_y)
			
		if gx != grid_x or gy != grid_y:
			$Wheels.play()
			t1.play("Forward")
			t2.play("Forward")
		else:
			$FoamError.play()
			anim.play("Error")
			
	if i == Ins.Backward:
		var gx = grid_x
		var gy = grid_y
	
		if direction == Dir.Left:
			grid.move_object_right(grid_x, grid_y)
		elif direction == Dir.Right:
			grid.move_object_left(grid_x, grid_y)
		elif direction == Dir.Down:
			grid.move_object_up(grid_x, grid_y)
		elif direction == Dir.Up:
			grid.move_object_down(grid_x, grid_y)
			
		if gx != grid_x or gy != grid_y:
			$WheelsBack.play()
			t1.play("Forward")
			t2.play("Forward")
		else:
			$FoamError.play()
			anim.play("Error")
		
	if i == Ins.Left:
		$Rotate.play()
		rotate_left()
		t2.play("Forward")
		t1.play("Backward")
		
	if i == Ins.Right:
		$Rotate.play()
		rotate_right()
		t2.play("Backward")
		t1.play("Forward")
		
	if i == Ins.Spin:
		$DoubleRotate.play()
		rotate_right()
		rotate_right()
		t2.play("Backward")
		t1.play("Forward")
		
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
			foam.position = $Sprite2/Sprite2/FoamSource.global_position + Vector2(-32, -32)
			foam.initial_target = Vector2(x * 64, y * 64)
			get_parent().call_deferred("add_child", foam)
			
			grid.set_grid_ref(x, y, foam)
			
			$Foam.play()
		else:
			$FoamError.play()
			anim.play("Error")
			
func set_dir_instant():
	$Sprite2.rotation_degrees = fmod(get_target_direction(), 360)

func _process(delta):
	if coordinator != null:
		$Number.visible = (not coordinator.is_playing) and (not coordinator.has_won)
		
	handle_pupil(delta)
	
	$Number.global_rotation_degrees = 0
	
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
