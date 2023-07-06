extends HSlider

var the_bus

export var which = "Master"

func db_to_val(db):
	return db2linear(db) * 100.0 # legacy: sliders are 100
	
func val_to_db(val):
	return linear2db(val / 100.0) # legacy: sliders are 100
	 
func _ready():
	the_bus = AudioServer.get_bus_index(which)
	value = db_to_val(AudioServer.get_bus_volume_db(the_bus))

func _on_changed(value):
	AudioServer.set_bus_volume_db(the_bus, val_to_db(value))
