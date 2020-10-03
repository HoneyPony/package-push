extends Node2D

var grid_x = 0
var grid_y = 0

var instructions = []
var pointer = 0

onready var world_position = position

var speed: Vector2 = Vector2(0, 0)
var time = 0

func is_package():
	return false

func update_grid(x, y):
	grid_x = x
	grid_y = y
	world_position = Vector2(x * 16, y * 12)
	
	speed = (world_position - position) * (1 / 0.2)
	time = 0.2

func is_movable():
	return true
	
func handle_instruction(ins, grid):
	pass

func tick(grid):
	if instructions.empty():
		return
	
	handle_instruction(instructions[pointer], grid)
	pointer = (pointer + 1) % instructions.size()

func _process(delta):
	position += speed * delta
	if time <= 0:
		speed = Vector2.ZERO
		position = world_position
	else:
		time -= delta
	
