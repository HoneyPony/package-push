extends Node2D

var is_first_time = true

func random_sound(arr: Array):
	var index = rand_range(0, arr.size())
	index = min(index, arr.size() - 1)
	
	arr[index].play()

var a
var b
var c

var beg

func aud(path):
	var node = AudioStreamPlayer.new()
	node.stream = load(path)
	node.bus = "SAM"
	add_child(node)
	return node

func _ready():
	a = aud("res://sound/sam/goodchoice.wav")
	b = aud("res://sound/sam/trythisone.wav")
	c = aud("res://sound/sam/thislooksfun.wav")
	beg = aud("res://sound/sam/startatbeginning.wav")
	
func play():
	if is_first_time and Global.intended_level == 0:
		beg.play()
	else:
		random_sound([a, b, c])
	
	is_first_time = false
