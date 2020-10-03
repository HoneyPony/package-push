extends Control

onready var transition = get_node("SceneTransition")

func load_level(level):
	Global.intended_level = level
	
	transition.switch_scene("res://Game.tscn")
