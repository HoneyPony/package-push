extends HSlider

var the_bus

export var which = "Master"

var MIN = -40

func db_to_val(db):
	var t = (db - (MIN)) / (2 - (MIN))
	
	return 0 + 100 * t
	
func val_to_db(val):
	var t = val / 100.0
	
	return MIN + (2 - (MIN)) * t
	 
func _ready():
	the_bus = AudioServer.get_bus_index(which)
	value = db_to_val(AudioServer.get_bus_volume_db(the_bus))

func _on_changed(value):
	AudioServer.set_bus_volume_db(the_bus, val_to_db(value))
