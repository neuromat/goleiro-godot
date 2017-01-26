extends TextureFrame

var time  =0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("start").connect("pressed",self,"_on_button_pressed")

	OS.set_window_size(Vector2(800,450))
	OS.set_window_fullscreen(false)
	#como é a tela de splash, não faz sentido ser fullscreen...

	
func _on_button_pressed():
	get_node("/root/globalScript").goToScene("res://scenes/GUI/config/config.tscn")
	#get_tree().change_scene("res://cena_introducao.tscn")