extends Sprite

var angle = 90

export var which = 0

signal alert_rotate

onready var ui = get_parent()

func _ready():
	
	
	angle = 90
	rotation_degrees = 90
	
func _process(delta):
	visible = not ui.playing
	if ui.playing:
		return
	
	var mouse = get_global_mouse_position()
	
	var size = texture.get_size()
	
	var rect = Rect2(global_position - size * 0.5, size)
	
	if rect.has_point(mouse):
		modulate = Color(1.1, 1.1, 1.1, 1.0)
		
		if Input.is_action_just_pressed("mouse"):
			angle += 90
			angle = angle % 360
			
			rotation_degrees = angle
			
			emit_signal("alert_rotate", which, angle)
	else:
		modulate = Color(1, 1, 1, 1)
