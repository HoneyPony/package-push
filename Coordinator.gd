extends Node2D

var is_playing = false
var is_manual = false

var TIME_PER_TICK = 0.2
var tick_timer = 0

var AIR
var WALL
var ROBOT_FILTER

var grid_ref = []
var goals = []
var width = 6
var height = 6

var robots = []

onready var the_ui = get_node("../Camera/CanvasLayer/UI")

class Level:
	var bots = []
	var boxes = []
	
	var width
	var height
	var grid
	
	var columns
	var rows
	
	func _init(bots_, boxes_, width_, height_, grid_, columns_, rows_):
		bots = bots_
		boxes = boxes_
		width = width_
		height = height_
		grid = grid_
		columns = columns_
		rows = rows_
		
var current_level: Level
var entity_parent = null

var Robot = preload("res://Robot.tscn")
var Package = preload("res://Package.tscn")

var FinishTile = preload("res://vector/FinishTile.tscn")
var FilterTile = preload("res://vector/FilterTile.tscn")

func reload_tile(x, y):
	var index = y * width + x
	
	grid_ref[index] = level_to_grid_ref(current_level.grid[index])
	
func level_to_grid_ref(i):
	if i == 0:
		return WALL
	elif i == 3:
		return ROBOT_FILTER
	else:
		return AIR

func place_object(obj, pos):
	obj.grid_x = pos.x
	obj.grid_y = pos.y
	obj.position = pos * 64
	set_grid_ref(pos.x, pos.y, obj)
	
func reload_level(lvl: Level):
	if entity_parent != null:
		entity_parent.queue_free()
		entity_parent = null
		
	robots.clear()
		
	entity_parent = Node2D.new()
	get_parent().call_deferred("add_child", entity_parent)
	
	width = lvl.width
	height = lvl.height
	
	grid_ref.clear()
	for i in lvl.grid:		
		grid_ref.append(level_to_grid_ref(i))
		
	var bot_index = 0
	for r in lvl.bots:
		var bot = Robot.instance()
		entity_parent.add_child(bot)
		place_object(bot, r)
		robots.append(bot)
		
		bot.direction = the_ui.get_robot_direction(bot_index)
		bot.set_dir_instant()
		bot_index += 1
		
	for p in lvl.boxes:
		var pkg = Package.instance()
		entity_parent.add_child(pkg)
		place_object(pkg, p)
		
func map_to_tile(grid_num):
	return grid_num - 1
	
func fake_tile(type, x, y):
	var t = type.instance()
	t.position = Vector2(x, y) * 64
	get_node("../TileMap").call_deferred("add_child", t)
		
func load_level(lvl: Level):
	var tilemap = get_node("../TileMap")
	
	tilemap.clear()
	
	width = lvl.width
	height = lvl.height
	
	var x = 0
	var y = 0
	for i in lvl.grid:
		var cell = map_to_tile(i)
		
		if i == 2:
			fake_tile(FinishTile, x, y)
			cell = -1
			
		if i == 3:
			fake_tile(FilterTile, x, y)
			cell = 0
		
		tilemap.set_cell(x, y, cell)
		x += 1
		if x >= width:
			x = 0
			y += 1
	
	goals.clear()
	for gx in range(0, width):
		for gy in range(0, height):
			if get_grid_source(gx, gy) == 2:
				goals.append(Vector2(gx, gy))
	
	reload_level(lvl)
	
	the_ui.columns = lvl.columns
	the_ui.rows = lvl.rows
	the_ui.call_deferred("setup")
	
func reload_current_level():
	reload_level(current_level)
	
func _ready():
	AIR = Node2D.new()
	WALL = Node2D.new()
	ROBOT_FILTER = Node2D.new()
	
	if Global.intended_level == 0:
		the_ui.tutorial_step = 1
		the_ui.tutorial_end = 10
		current_level = Level.new([Vector2(0, 0)], [Vector2(3, 0)], 7, 1, [
			1, 1, 1, 1, 1, 1, 2
		], 5, 1)
	
	if Global.intended_level == 1:
		the_ui.tutorial_step = 11
		the_ui.tutorial_end = 18
		current_level = Level.new([Vector2(0, 2)], [Vector2(2, 0)], 5, 5, [
			2, 1, 1, 1, 1,
			0, 0, 0, 0, 1,
			1, 0, 0, 0, 1,
			1, 0, 0, 0, 1,
			1, 1, 1, 1, 1
		], 5, 1)
		
	
	if Global.intended_level == 2:
		current_level = Level.new([Vector2(2, 2)], [Vector2(2, 0)], 7, 7, [
			0, 2, 1, 1, 1, 0, 0,
			0, 0, 0, 0, 1, 0, 0, 
			1, 1, 1, 0, 1, 1, 1,
			1, 0, 0, 0, 0, 0, 1,
			1, 1, 1, 0, 1, 1, 1,
			0, 0, 1, 0, 1, 0, 0,
			0, 0, 1, 1, 1, 0, 0
		], 9, 1)
	
	if Global.intended_level == 3:
		the_ui.tutorial_step = 19
		the_ui.tutorial_end = 22
		current_level = Level.new([Vector2(0, 0)], [Vector2(4, 0)], 10, 1, [
			1, 1, 1, 1, 1, 3, 1, 1, 1, 2
		], 3, 1) # 3+ x 1
		
	if Global.intended_level == 4:
		the_ui.tutorial_step = 23
		the_ui.tutorial_end = 23
		current_level = Level.new([Vector2(1, 0), Vector2(4, 4)], [Vector2(4, 1)], 7, 5, [
			0, 1, 1, 1, 3, 1, 2,
			0, 0, 0, 0, 1, 0, 0,
			0, 0, 0, 0, 3, 0, 0,
			0, 0, 0, 0, 1, 0, 0,
			0, 0, 0, 0, 1, 0, 0
		], 3, 2) # 3+ x 1

# Kind of a weird level....
#		current_level = Level.new([Vector2(2, 4)], [Vector2(4, 1)], 9, 5, [
#			0, 0, 1, 0, 0, 0, 0, 0, 0,
#			1, 1, 1, 1, 1, 1, 3, 1, 2,
#			0, 0, 1, 0, 0, 0, 0, 0, 0,
#			0, 0, 1, 0, 0, 0, 0, 0, 0,
#			0, 0, 1, 0, 0, 0, 0, 0, 0,
#		], 3, 1) # 3+ x 1
	


	if Global.intended_level == 5:
		current_level = Level.new([Vector2(1, 2), Vector2(0, 6), Vector2(5, 7)], [Vector2(1, 4), Vector2(3, 6), Vector2(5, 4)], 6, 8, [
			0, 0, 0, 0, 0, 2,
			0, 0, 0, 0, 0, 2,
			0, 1, 0, 0, 0, 2,
			0, 1, 0, 0, 0, 1,
			0, 1, 0, 0, 0, 1,
			0, 1, 0, 0, 0, 1,
			1, 1, 1, 1, 1, 1,
			0, 0, 0, 0, 0, 1
		], 3, 3)


	if Global.intended_level == 6:
		current_level = Level.new([Vector2(0, 4), Vector2(5, 6)], [Vector2(4, 4), Vector2(5, 3)], 9, 7, [
			0, 0, 0, 0, 0, 2, 0, 0, 0,
			0, 0, 0, 0, 0, 1, 0, 0, 0,
			0, 0, 0, 0, 0, 3, 0, 0, 0,
			0, 0, 0, 0, 0, 1, 0, 0, 0,
			1, 1, 1, 1, 1, 1, 1, 1, 2, 
			0, 0, 0, 0, 0, 1, 0, 0, 0,
			0, 0, 0, 0, 0, 1, 0, 0, 0
		], 6, 2) # 6 x 2

	if Global.intended_level == 7:
		current_level = Level.new([Vector2(0, 5), Vector2(4, 5)], [Vector2(4, 2), Vector2(4, 8)], 5, 11, [
			0, 0, 0, 0, 2,
			0, 0, 0, 0, 1,
			0, 0, 0, 0, 1,
			0, 0, 0, 0, 1,
			0, 0, 0, 0, 1,
			1, 1, 1, 1, 1,
			0, 0, 0, 0, 1,
			0, 0, 0, 0, 1,
			0, 0, 0, 0, 1,
			0, 0, 0, 0, 1,
			0, 0, 0, 0, 2
		], 3, 2) # 3 x 2
		
	if Global.intended_level == 8:
		current_level = Level.new([Vector2(1, 2), Vector2(0, 6), Vector2(5, 7)], [Vector2(1, 4), Vector2(2, 6), Vector2(5, 4)], 6, 8, [
			0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0,
			0, 1, 0, 0, 0, 2,
			0, 1, 0, 0, 0, 1,
			0, 1, 0, 0, 0, 1,
			0, 1, 0, 0, 0, 1,
			1, 1, 1, 2, 2, 1,
			0, 0, 0, 0, 0, 1
		], 3, 3)


	if Global.intended_level == 9:
		current_level = Level.new([Vector2(0, 0), Vector2(11, 0)], [Vector2(2, 0), Vector2(9, 0)], 12, 1, [
			1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1
		], 3, 2) # 3+ x 1
	
		
	if Global.intended_level == 10:
		current_level = Level.new([Vector2(0, 0)], [Vector2(1, 0), Vector2(1, 1)], 7, 2, [
			1, 1, 1, 1, 1, 1, 2,
			1, 1, 1, 1, 1, 1, 2
		], 9, 1)
		
	if Global.intended_level == 11:
		current_level = Level.new([Vector2(0, 0)], [Vector2(4, 2)], 6, 6, [
			1, 0, 0, 0, 2, 0,
			1, 0, 0, 0, 1, 0,
			1, 0, 0, 0, 1, 0,
			1, 0, 0, 0, 1, 0,
			1, 1, 1, 1, 1, 1,
			1, 0, 0, 0, 0, 0
		], 3, 1) # 3+ x 1
	
	if Global.intended_level == 12:
		current_level = Level.new([Vector2(4, 4), Vector2(9, 4)], [Vector2(4, 2), Vector2(4, 6), Vector2(2, 4), Vector2(6, 4), Vector2(9, 2), Vector2(9, 6)], 10, 9, [
			0, 0, 0, 0, 2, 0, 0, 0, 0, 2,
			0, 0, 0, 0, 1, 0, 0, 0, 0, 1,
			0, 0, 0, 0, 1, 0, 0, 0, 0, 1,
			0, 0, 0, 0, 1, 0, 0, 0, 0, 1,
			2, 1, 1, 1, 1, 1, 1, 1, 2, 1,
			0, 0, 0, 0, 1, 0, 0, 0, 0, 1,
			0, 0, 0, 0, 1, 0, 0, 0, 0, 1,
			0, 0, 0, 0, 1, 0, 0, 0, 0, 1,
			0, 0, 0, 0, 2, 0, 0, 0, 0, 2
		], 4, 2) # 3+ x 1
		
	if Global.intended_level == 1000:
		current_level = Level.new([Vector2(1, 0), Vector2(0, 4), Vector2(4, 5), Vector2(5, 1)], [Vector2(3, 1), Vector2(1, 2), Vector2(2, 4), Vector2(4, 3)], 6, 6, [
			0, 1, 0, 0, 2, 0,
			2, 1, 3, 1, 1, 1,
			0, 1, 0, 0, 3, 0,
			0, 3, 0, 0, 1, 0,
			1, 1, 1, 3, 1, 2,
			0, 2, 0, 0, 1, 0
		], 8, 4)
	
	load_level(current_level)
	
func get_grid_ref(x, y):
	return grid_ref[y * width + x]
	
func set_grid_ref(x, y, f):
	grid_ref[y * width + x] = f
	
func get_grid_source(x, y):
	return current_level.grid[y * width + x]
	
func is_air(x, y, robot_filter_is_air = true):
	if x < 0:
		return false
	if y < 0:
		return false
	if x >= width:
		return false
	if y >= height:
		return false
	var ref = get_grid_ref(x, y)
	if ref == AIR:
		return true
	if robot_filter_is_air:
		if ref == ROBOT_FILTER:
			return true
	return false
	
func is_movable(obj):
	if obj == null:
		return false
	if obj == AIR:
		return false
	if obj == WALL:
		return false
	if obj == ROBOT_FILTER:
		return false
	if obj.is_movable():
		return true
	return false
	
func is_usable(f):
	return f != null and f != AIR and f != WALL
	
func robot_filter_condition(x, y, x0, y0):
	var tile: Node2D = get_grid_ref(x, y)
	if tile.get_groups().find("Robots") == -1:
		return false
		
	if get_grid_source(x0, y0) == 3:
		return true
		
	return false
		
	
func move_object_right(x, y):
	var x0 = x + 1
	
	if x0 >= width:
		return
		
	if robot_filter_condition(x, y, x0, y):
		return
		
	var air = false
		
	while x0 < width:
		if is_air(x0, y):
			air = true
			break
		elif not is_movable(get_grid_ref(x0, y)):
			return
		x0 += 1
		
	if not air:
		return
			
	# Now we know that we can move, properly
	while x0 != x:	
		var gf = get_grid_ref(x0 - 1, y)
		if is_usable(gf):
			gf.update_grid(x0, y)
		set_grid_ref(x0, y, gf)
		x0 -= 1
		
	#set_grid_ref(x, y, AIR)
	reload_tile(x, y)
	
func move_object_left(x, y):
	var x0 = x - 1
	
	if x0 < 0:
		return
		
	if robot_filter_condition(x, y, x0, y):
		return
		
	var air = false
		
	while x0 >= 0:
		if is_air(x0, y):
			air = true
			break
		elif not is_movable(get_grid_ref(x0, y)):
			return
		x0 -= 1
		
	if not air:
		return
			
	# Now we know that we can move, properly
	while x0 != x:	
		var gf = get_grid_ref(x0 + 1, y)
		if is_usable(gf):
			gf.update_grid(x0, y)
		set_grid_ref(x0, y, gf)
		x0 += 1
		
	#set_grid_ref(x, y, AIR)
	reload_tile(x, y)
	
func move_object_down(x, y):
	var y0 = y + 1
	
	if y0 >= height:
		return
		
	if robot_filter_condition(x, y, x, y0):
		return
		
	var air = false
		
	while y0 < height:
		if is_air(x, y0):
			air = true
			break
		elif not is_movable(get_grid_ref(x, y0)):
			return
		y0 += 1
		
	if not air:
		return
			
	# Now we know that we can move, properly
	while y0 != y:	
		var gf = get_grid_ref(x, y0 - 1)
		if is_usable(gf):
			gf.update_grid(x, y0)
		set_grid_ref(x, y0, gf)
		y0 -= 1
		
	#set_grid_ref(x, y, AIR)
	reload_tile(x, y)
		
func move_object_up(x, y):
	var y0 = y - 1
	
	if y0 < 0:
		return
		
	if robot_filter_condition(x, y, x, y0):
		return
		
	var air = false
		
	while y0 >= 0:
		if is_air(x, y0):
			air = true
			break
		elif not is_movable(get_grid_ref(x, y0)):
			return
		y0 -= 1
		
	if not air:
		return
			
	# Now we know that we can move, properly
	while y0 != y:	
		var gf = get_grid_ref(x, y0 + 1)
		if is_usable(gf):
			gf.update_grid(x, y0)
		set_grid_ref(x, y0, gf)
		y0 += 1
		
	#set_grid_ref(x, y, AIR)
	reload_tile(x, y)
	
var tick_id = 0
		
func tick():
	#get_tree().call_group("Robots", "tick", self)
	robots[tick_id].tick(self)
		
	tick_id = (tick_id + 1) % robots.size()
	
	for g in goals:
		var obj = get_grid_ref(g.x, g.y)
		if obj == AIR or obj == WALL or obj == ROBOT_FILTER:
			return
		
		if not obj.is_package():
			return
	# Won the level!
	the_ui.won()
	is_playing = false
	
func play(delta):
	
	tick_timer -= delta
	if tick_timer <= 0:
		tick_timer = TIME_PER_TICK
		tick()
		
func manual_step(ui):
	if not is_playing:
		begin_playing(ui)
		
	is_manual = true
	
	tick()
		
func begin_playing(ui):
	tick_id = 0
	
	var index = 0
	for r in robots:
		var ins: Array = ui.instructions[index]
		r.instructions = ins.duplicate()
		index += 1
		
		r.pointer = 0
	
	is_playing = true
	tick_timer = TIME_PER_TICK
	
	is_manual = false
	
func stop_playing():
	is_playing = false
	reload_current_level()
	
func update_base_rotation(index, rot):
	if is_playing:
		return
	
	robots[index].direction = rot
	
func _process(delta):
	#if Input.is_action_pressed("key_play"):
	#	is_playing = true
		#tick_timer = TIME_PER_TICK
		
	if is_playing and not is_manual:
		play(delta)
