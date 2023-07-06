extends TextureButton
	

func _on_pressed():
	get_node("../SceneTransition").switch_scene(Global.MainMenu)
