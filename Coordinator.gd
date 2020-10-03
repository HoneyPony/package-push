extends Node2D

var is_playing = false

var TIME_PER_TICK = 0.2
var tick_timer = 0

var AIR
var WALL

var grid_ref = []
var goals = [Vector2(4, 0)]
var width = 5
var height = 5

var robots = []

func _ready():
	AIR = Node2D.new()
	WALL = Node2D.new()
	
	grid_ref = [get_node("../WheelBot"), WALL, WALL, WALL, AIR, AIR, WALL, WALL, WALL, AIR, AIR, WALL, WALL, WALL, AIR, AIR, WALL, WALL, WALL, get_node("../Node2D"), AIR, AIR, AIR, AIR, AIR]

	robots = [get_node("../WheelBot")]
	
func get_grid_ref(x, y):
	return grid_ref[y * width + x]
	
func set_grid_ref(x, y, f):
	grid_ref[y * width + x] = f
	
func is_movable(obj):
	if obj == null:
		return false
	if obj == AIR:
		return false
	if obj == WALL:
		return false
	if obj.is_movable():
		return true
	return false
	
func is_usable(f):
	return f != null and f != AIR and f != WALL
	
func move_object_right(x, y):
	var x0 = x + 1
	
	if x0 >= width:
		return
		
	while x0 < width:
		if get_grid_ref(x0, y) == AIR:
			break
		elif not is_movable(get_grid_ref(x0, y)):
			return
		x0 += 1
			
	# Now we know that we can move, properly
	while x0 != x:	
		var gf = get_grid_ref(x0 - 1, y)
		if is_usable(gf):
			gf.update_grid(x0, y)
		set_grid_ref(x0, y, gf)
		x0 -= 1
		
	set_grid_ref(x, y, AIR)
	
func move_object_left(x, y):
	var x0 = x - 1
	
	if x0 < 0:
		return
		
	while x0 >= 0:
		if get_grid_ref(x0, y) == AIR:
			break
		elif not is_movable(get_grid_ref(x0, y)):
			return
		x0 -= 1
			
	# Now we know that we can move, properly
	while x0 != x:	
		var gf = get_grid_ref(x0 + 1, y)
		if is_usable(gf):
			gf.update_grid(x0, y)
		set_grid_ref(x0, y, gf)
		x0 += 1
		
	set_grid_ref(x, y, AIR)
	
func move_object_down(x, y):
	var y0 = y + 1
	
	if y0 >= height:
		return
		
	while y0 < height:
		if get_grid_ref(x, y0) == AIR:
			break
		elif not is_movable(get_grid_ref(x, y0)):
			return
		y0 += 1
			
	# Now we know that we can move, properly
	while y0 != y:	
		var gf = get_grid_ref(x, y0 - 1)
		if is_usable(gf):
			gf.update_grid(x, y0)
		set_grid_ref(x, y0, gf)
		y0 -= 1
		
	set_grid_ref(x, y, AIR)
		
func move_object_up(x, y):
	var y0 = y - 1
	
	if y0 < 0:
		return
		
	while y0 >= 0:
		if get_grid_ref(x, y0) == AIR:
			break
		elif not is_movable(get_grid_ref(x, y0)):
			return
		y0 -= 1
			
	# Now we know that we can move, properly
	while y0 != y:	
		var gf = get_grid_ref(x, y0 + 1)
		if is_usable(gf):
			gf.update_grid(x, y0)
		set_grid_ref(x, y0, gf)
		y0 += 1
		
	set_grid_ref(x, y, AIR)
	
var tick_id = 0
		
func tick():
	#get_tree().call_group("Robots", "tick", self)
	robots[tick_id].tick(self)
		
	tick_id = (tick_id + 1) % robots.size()
	
	for g in goals:
		var obj = get_grid_ref(g.x, g.y)
		if obj == AIR or obj == WALL:
			return
		
		if not obj.is_package():
			return
			
	
			
	# Won the level!
	
func play(delta):
	tick_timer -= delta
	if tick_timer <= 0:
		tick_timer = TIME_PER_TICK
		tick()
	
func _process(delta):
	if Input.is_action_pressed("key_play"):
		is_playing = true
		tick_timer = TIME_PER_TICK
		
	if is_playing:
		play(delta)
