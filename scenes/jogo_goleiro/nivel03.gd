extends Node2D
var root

func _button_voltaMenu_pressed():
	root.goToScene("res://scenes/GUI/choose_game/choose_game.tscn")
	
func _button_fimJogo_pressed():
	get_node("janelaFim").show()
	get_node("b_endGame").hide()
	
func _quit():
	root.quit()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	root = get_node("/root/globalScript")
	get_node("b_endGame").connect("pressed",self,"_button_fimJogo_pressed")
	get_node("janelaFim/b_voltaMenu").connect("pressed",self,"_button_voltaMenu_pressed")
	get_node("janelaFim/b_sairGame").connect("pressed",self,"_quit")
	get_node("janelaFim").hide()

func _process(delta):
	#if Input.is_action_pressed("ui_enter_name") && choosed : root.nextScene()