extends Node2D

onready var slots = $Slots
onready var cursor = $Cursor

onready var sp_Forward = load("res://vector/Prog/Forward.svg")
onready var sp_Left = load("res://vector/Prog/Left.svg")
onready var sp_Right = load("res://vector/Prog/Right.svg")
onready var sp_Foam = load("res://vector/Prog/Foam.svg")

var Robot = preload("res://Robot.gd")

var columns = 4
var rows = 1

var instructions = [[], [], [], [], []]

var held_instruction = null

var instruction_sprite = null

func setup():
	slots.region_rect.size.x = 46 * columns
	
	instructions = []
	for i in range(0, 5):
		var arr = []
		for x in range(0, columns):
			arr.append(null)
		instructions.append(arr)
		
func _ready():
	cursor.hide()
	
	setup()

func _on_new_foam():
	held_instruction = Robot.Ins.Foam
	cursor.texture = sp_Foam
	cursor.show()
	
func get_cell_pos(cell: Vector2):
	var pos = slots.global_position
#	pos += Vector2(23, 17)
	pos += Vector2(3, 2)
	pos.x += cell.x * 46
	pos.y += cell.y * 34
	return pos
	
func cell_dist(cell: Vector2):
	var pos = slots.global_position
	pos += Vector2(23, 17)
	pos.x += cell.x * 46
	pos.y += cell.y * 34
	return (get_global_mouse_position() - pos).length()
	
func generate_instruction_sprite():
	if instruction_sprite != null:
		instruction_sprite.queue_free()
		instruction_sprite = null
		
	instruction_sprite = Node2D.new()
	add_child(instruction_sprite)
	
	var y = 0
	for row in instructions:
		var x = 0
		for item in row:
			if item != null:
				var pos = get_cell_pos(Vector2(x, y))
				var spr = Sprite.new()
				spr.centered = false
				
				instruction_sprite.add_child(spr)
				spr.global_position = pos
				if item == Robot.Ins.Foam:
					spr.texture = sp_Foam
			
			x += 1
			
		y += 1
	
func _process(delta):
	cursor.global_position = get_global_mouse_position()
	
	if Input.is_action_just_released("mouse"):
		if held_instruction != null:
			var closest_cell = Vector2(0, 0)
			var closest_cell_dist = 0
			
			closest_cell_dist = cell_dist(closest_cell)
			
			for x in range(0, columns):
				for y in range(0, rows):
					var cell = Vector2(x, y)
					var dist = cell_dist(cell)
					if dist < closest_cell_dist:
						closest_cell = cell
						closest_cell_dist = dist
						
			if closest_cell_dist < 60:
				instructions[closest_cell.y][closest_cell.x] = held_instruction
				generate_instruction_sprite()
				
		held_instruction = null
		cursor.hide()
	
