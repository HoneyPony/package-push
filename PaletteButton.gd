extends Sprite

signal clicked

func _process(delta):
	var mouse = get_global_mouse_position()
	
	var size = Vector2(40, 30)
	
	var rect = Rect2(global_position, size)
	
	if rect.has_point(mouse):
		if Input.is_action_just_pressed("mouse"):
			emit_signal("clicked")
