extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_presssed():
	# We only play the voice if we've been in a level. This is to make it less
	# annoying switching back and forth between screens
	if Global.can_play_menu_voice:
		PlayGame.play()
		Global.can_play_menu_voice = false
	get_node("../SceneTransition").switch_scene(Global.LevelSelect)
