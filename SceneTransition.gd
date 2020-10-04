extends TextureRect

var target_scene = null
var leave_timer = 0

export var use_menu_music = false
export var play_music = true

var approach_timer = 1.0

var SPEED = 1.2

func _ready():
	if Global.first_load:
		approach_timer = 0
		Global.first_load = false
		material.set_shader_param("time", 0.0)
	else:
		material.set_shader_param("time", 1.0)
		$Arrive.play()
		
	if play_music:
		if use_menu_music:
			Global.menu_music()
		else:
			Global.game_music()

func _process(delta):
	if approach_timer > 0:
		approach_timer -= delta * SPEED
		material.set_shader_param("time", approach_timer)
	else:
		material.set_shader_param("time", 0)
		
	if leave_timer > 0:
		leave_timer -= delta * SPEED
		material.set_shader_param("time", 1.0 - leave_timer)
	else:
		if target_scene != null:
			get_tree().change_scene(target_scene)
		
func switch_scene(target):
	target_scene = target
	leave_timer = 1.0
	$Leave.play()
		
