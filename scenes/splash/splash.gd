extends TextureFrame

var time  = 0

func _ready():
	#OS.set_window_size(Vector2(800,450))
	OS.set_window_fullscreen(true)
	set_process(true)
	
func _process(delta):
	time += delta
	if time >= 4: get_node("/root/globalScript").goToScene("res://scenes/GUI/config/config.tscn")