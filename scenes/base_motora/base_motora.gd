extends Control
var tapped=false

# class member variables go here, for example:
# var a = 2
var root

func _button_backMenu_pressed():
	root.goToScene("res://scenes/GUI/choose_game/choose_game.tscn")

func _draw():
    var r = Rect2( Vector2(), get_size() )
    if (tapped):
        draw_rect(r, Color(1,0,0) )
    else:
        draw_rect(r, Color(0,0,1) )

func _input_event(ev):
	if (ev.type==InputEvent.MOUSE_BUTTON and ev.pressed):
		if tapped==true: tapped = false
		else: tapped = true
		update()

func _button_quit_pressed():
	get_tree().quit()
	
func _ready():
	root = get_node("/root/globalScript")
	get_node("b_backMenu").connect("pressed",self,"_button_backMenu_pressed")
	get_node("quit").connect("pressed",self,"_button_quit_pressed")