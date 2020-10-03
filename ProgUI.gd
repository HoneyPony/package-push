extends Node2D

onready var slots = $Slots
onready var cursor = $Cursor

onready var sp_Forward = load("res://vector/Prog/Forward.svg")
onready var sp_Left = load("res://vector/Prog/Left.svg")
onready var sp_Right = load("res://vector/Prog/Right.svg")
onready var sp_Foam = load("res://vector/Prog/Foam.svg")
onready var sp_Backward = load("res://vector/Prog/Backward.svg")
onready var sp_Spin = load("res://vector/Prog/Spin.svg")

var Robot = preload("res://Robot.gd")

var ProgInstruct = preload("res://ProgInstruct.tscn")

var columns = 1
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
	
func tex_from_ins(ins):
	if ins == Robot.Ins.Foam:
		return sp_Foam
	if ins == Robot.Ins.Forward:
		return sp_Forward
	if ins == Robot.Ins.Left:
		return sp_Left
	if ins == Robot.Ins.Right:
		return sp_Right
	if ins == Robot.Ins.Backward:
		return sp_Backward
	if ins == Robot.Ins.Spin:
		return sp_Spin
	
func update_cursor():
	if held_instruction == null:
		cursor.hide()
	else:
		cursor.texture = tex_from_ins(held_instruction)
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
				var spr = ProgInstruct.instance()
				spr.cell = Vector2(x, y)
				spr.connect("clicked", self, "_on_instruct")
				
				instruction_sprite.add_child(spr)
				spr.global_position = pos
				spr.instruction = item
				spr.texture = tex_from_ins(item)
			
			x += 1
			
		y += 1
		
func _on_instruct(x):
	var cell = x.cell
	instructions[cell.y][cell.x] = null
	
	generate_instruction_sprite()
	
	held_instruction = x.instruction
	update_cursor()
	
func ensure_viewport_position():
	var viewport = get_viewport()
	var height = viewport.size.y
	
	var half_height = height * 0.5
	var y = height - 200
	position.y = y
	position.x = viewport.size.x * 0.5
	
var dragging_camera = false
var drag_last_mouse = Vector2(0, 0)

var playing = false
	
func always_process(delta):
	ensure_viewport_position()
	
	if dragging_camera:
		var mouse = get_local_mouse_position()
		var camera = get_parent().get_parent()
		camera.position -= (mouse - drag_last_mouse)
		drag_last_mouse = mouse
		
	if Input.is_action_just_released("mouse"):
		dragging_camera = false
		
	if Input.is_action_just_pressed("mouse"):
		var mouse = get_global_mouse_position()
		if mouse.y < global_position.y:
			dragging_camera = true
			drag_last_mouse = get_local_mouse_position()
	
func _process(delta):
	always_process(delta)
	
	if playing:
		cursor.hide()
		held_instruction = null
		return
		
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
						
			if closest_cell_dist < 50:
				instructions[closest_cell.y][closest_cell.x] = held_instruction
				generate_instruction_sprite()
				
		held_instruction = null
		cursor.hide()
	

func _on_new_foam():
	held_instruction = Robot.Ins.Foam
	update_cursor()

func _on_new_right():
	held_instruction = Robot.Ins.Right
	update_cursor()

func _on_new_left():
	held_instruction = Robot.Ins.Left
	update_cursor()

func _on_new_forward():
	held_instruction = Robot.Ins.Forward
	update_cursor()

func _on_new_backward():
	held_instruction = Robot.Ins.Backward
	update_cursor()

func _on_new_spin():
	held_instruction = Robot.Ins.Spin
	update_cursor()


var sp_Play = preload("res://vector/Prog/Play.svg")
var sp_Stop = preload("res://vector/Prog/Stop.svg")

onready var coordinator = get_node("../../../Coordinator")

func _on_play():
	if playing:
		$Play.texture = sp_Play
		playing = false
		coordinator.stop_playing()
	else:
		$Play.texture = sp_Stop
		playing = true
		coordinator.begin_playing(self)

func get_robot_direction(index):
	var angle = get_node("Rot" + String(index)).angle
	
	var dir = Robot.Dir.Up
	if angle > 80:
		dir = Robot.Dir.Right
	if angle > 170:
		dir = Robot.Dir.Down
	if angle > 260:
		dir = Robot.Dir.Left
		
	return dir

func _on_alert_rotate(which, angle):
	if which >= rows:
		return
	
	var dir = Robot.Dir.Up
	if angle > 80:
		dir = Robot.Dir.Right
	if angle > 170:
		dir = Robot.Dir.Down
	if angle > 260:
		dir = Robot.Dir.Left
	
	coordinator.update_base_rotation(which, dir)

func _on_back():
	get_node("/root/Root/CanvasLayer/SceneTransition").switch_scene("res://LevelSelect.tscn")
