extends Node

var intended_level = 14

var first_load = true

var music = -1

func menu_music():
	if music == 0:
		return
		
	music = 0
	GameMusic.stop()
	MenuMusic.play()
		
func game_music():
	GameMusic.stream_paused = false
	if music == 1:
		return
		
	music = 1
	MenuMusic.stop()
	GameMusic.play()
	
