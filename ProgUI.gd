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

var tutorial_step = 0
var tutorial_end = -5

func setup():
	var sz = 46 * columns
	slots.region_rect.size.x = 46 * columns
	
	$Slots/Unused2.region_rect.size.x = sz
	$Slots/Unused3.region_rect.size.x = sz
	$Slots/Unused4.region_rect.size.x = sz
	$Slots/Unused5.region_rect.size.x = sz
	
	$Slots/Unused2.visible = rows < 2
	$Slots/Unused3.visible = rows < 3
	$Slots/Unused4.visible = rows < 4
	$Slots/Unused5.visible = rows < 5
	
	instructions = []
	for i in range(0, 5):
		var arr = []
		for x in range(0, columns):
			arr.append(null)
		instructions.append(arr)
		
	if tutorial_step > 0:
		show_tutorial_step(tutorial_step)
	else:
		# Hide all outlines
		show_tutorial_step(0)
		
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
		$Pickup.play()


	
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
				spr.ui = self
				
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
	var y = height - 250
	position.y = y
	position.x = viewport.size.x * 0.5
	
	position.x -= 235
	
var dragging_camera = false
var drag_last_mouse = Vector2(0, 0)

var playing = false

onready var s_highlight = get_node("SlotHighlight")
	
func always_process(delta):
	s_highlight.visible = playing
	var highlight_cell = coordinator.get_current_tick()
	s_highlight.global_position = get_cell_pos(highlight_cell) - Vector2(2, 0)
	
	if highlight_cell.x < 0 or highlight_cell.y < 0:
		s_highlight.visible = false
	
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
			
	if Input.is_action_just_released("spacebar"):
		tutorial_step += 1
		if tutorial_step <= tutorial_end:
			show_tutorial_step(tutorial_step)
		else:
			hide_tut(tutorial_end)
			show_tutorial_step(0)
			
		if tutorial_step <= tutorial_end + 1:
			$Tutorial.play()
	
func _process(delta):
	ensure_viewport_position()
	
	if has_won:
		if Input.is_action_just_released("mouse"):
			Global.intended_level += 1
			get_node("/root/Root/CanvasLayer/SceneTransition").switch_scene("res://Game.tscn")
		return
	
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
				
				$Place.play()
			else:
				$Throwaway.play()	
			
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
		random_sound([$StopSAM, $ShutItDown, $StopPrgram])
	else:
		$Play.texture = sp_Stop
		playing = true
		coordinator.begin_playing(self)
		random_sound([$Go, $LetsGo, $Run, $RunPrgram, $PlaySAM])

func is_instruct_tick(cell):
	return cell == coordinator.get_current_tick()

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
	
func show_rot(which):
	return which < rows

func _on_alert_rotate(which, angle):
	if playing:
		return
	
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
	$Rotation.play()
	
func get_tutorial_node(step):
	var path = "CanvasLayer/Tutorial/Tutorial_" + String(step)
	return get_node(path)
	
func show_tut(f):
	if f < 1:
		return
	var n = get_tutorial_node(f)
	if n != null:
		n.show()

func hide_tut(f):
	if f < 1:
		return
	var n = get_tutorial_node(f)
	if n != null:
		n.hide()
	
func show_tutorial_step(step):
	var last = step - 1
	if last >= 1:
		hide_tut(last)
		
	if step <= 23:
		show_tut(step)
	$OutlinePalette.visible = step == 5
	$OutlineSlots.visible = step == 6
	$OutlineLeft.visible = step == 7
	$OutlinePlay.visible = step == 8
	$OutlineForward.visible = step == 9
	$OutlineBackward.visible = step == 10
	$OutlineRot.visible = step == 13
	$OutlineRLeft.visible = step == 15
	$OutlineRRight.visible = step == 16
	$OutlineFlip.visible = step == 17
	$OutlineFoam.visible = step == 21
	
func _on_back():
	get_node("/root/Root/CanvasLayer/SceneTransition").switch_scene("res://LevelSelect.tscn")


func _on_step():
	$Play.texture = sp_Stop
	playing = true
	coordinator.manual_step(self)
	
var has_won = false

func random_sound(arr: Array):
	var index = rand_range(0, arr.size())
	index = min(index, arr.size() - 1)
	
	arr[index].play()
	
func resume_music():
	# We can resume game music, but eh...
	# I like it being resuemd when we change levels better
	pass
	#print("resume music")
	#Global.game_music()
	#$WinMusic.stop()
	
func won():
	if has_won:
		return
	
	hide_tut(tutorial_step)
	show_tutorial_step(0)
	
	has_won = true
	$YouWon.show()
	$YouWon.frame = 0
	$YouWon.playing = true
	
	random_sound([$GoodJob, $YouWonSAM, $YouWonSAM2, $YouWonSAM3])
	
	GameMusic.stream_paused = true
	$WinMusic.play()
	
