extends TextureButton

export var level = 0

func _on_self_pressed():
	get_parent().get_parent().get_parent().load_level(level)
