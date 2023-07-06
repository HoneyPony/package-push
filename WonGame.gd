extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("../Music").play()
	get_node("../SAM").play()
	GameMusic.stream_paused = true
	
func _on_presssed():
	
	get_node("../SceneTransition").switch_scene(Global.LevelSelect)
