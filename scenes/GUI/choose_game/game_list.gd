extends Panel

var root
var choosed = false
var cena
func _button_baseMotora_pressed():
	#root.nextScene()
	choosed = true;
	cena = "res://scenes/base_motora/base_motora.tscn"
	get_node("b_baseMotora").hide()
	get_node("b_jogoGoleiro").hide()
	get_node("b_sair").hide()
	get_node("nomeUser").show()
	get_node("b_continuar").show()

func _button_baseMotoraTempo_pressed():
	root.nextScene()

func _button_jogoGoleiro_pressed():
	#root.goToScene("res://jogo_goleiro/nivel01.tscn")
	choosed = true;
	cena = "res://scenes/jogo_goleiro/nivel01.tscn"
	get_node("b_baseMotora").hide()
	get_node("b_jogoGoleiro").hide()
	get_node("b_sair").hide()
	get_node("nomeUser").show()
	get_node("b_continuar").show()

func _button_baseMemoria_pressed():
	pass

func _button_continuar_pressed():
	print(get_node("nomeUser").get_text())
	if choosed: root.goToScene(cena)
	
func _quit():
	root.quit()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	root = get_node("/root/globalScript")
	get_node("b_baseMotora").connect("pressed",self,"_button_baseMotora_pressed")
	#get_node("b_baseMotoraTempo").connect("pressed",self,"_button_baseMotoraTempo_pressed")
	get_node("b_jogoGoleiro").connect("pressed",self,"_button_jogoGoleiro_pressed")
	#get_node("b_baseMemoria").connect("pressed",self,"_button_baseMemoria_pressed")
	get_node("b_continuar").connect("pressed",self,"_button_continuar_pressed")
	get_node("b_sair").connect("pressed",self,"_quit")
	get_node("nomeUser").hide()
	#get_node("b_continuar").hide()

func _process(delta):
	if Input.is_action_pressed("ui_enter_name") && choosed : root.nextScene()