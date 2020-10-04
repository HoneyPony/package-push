extends Sprite

var cell
var instruction
var ui

signal clicked

func _process(delta):
	if ui.has_won:
		return
	
	var mouse = get_global_mouse_position()
	
	var size = Vector2(40, 30)
	
	var rect = Rect2(global_position, size)
	
	if rect.has_point(mouse):
		modulate = Color(1.1, 1.1, 1.1, 1.0)
		if Input.is_action_just_pressed("mouse"):
			emit_signal("clicked", self)
	else:
		modulate = Color(1, 1, 1, 1.0)
