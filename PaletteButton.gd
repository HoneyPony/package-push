extends Sprite

signal clicked

onready var ui = get_node("/root/Root/Camera/CanvasLayer/UI")

func _process(delta):
	if ui.has_won:
		return
	
	var mouse = get_global_mouse_position()
	
	var size = texture.get_size()
	
	var rect = Rect2(global_position, size)
	
	if rect.has_point(mouse):
		modulate = Color(1.1, 1.1, 1.1, 1.0)
		
		if Input.is_action_just_pressed("mouse"):
			emit_signal("clicked")
	else:
		modulate = Color(1, 1, 1, 1)
