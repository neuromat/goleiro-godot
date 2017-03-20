extends TextureFrame

var globalScript
var globalConfig
var choosed = false
var cena = ""

func _button_baseMotoraTempo_pressed():
	globalScript.nextScene()

func _button_jogoGoleiro_pressed():
	choosed = true;
	cena = "res://scenes/jogo_goleiro/nivel01.tscn"

	get_node("b_jogoGoleiro").hide()
	get_node("b_sair").hide()
	get_node("description").hide()
	get_node("nomeUser").show()
	get_node("b_continuar").show()
	get_node("nomeUser").grab_focus()
	#get_node("nomeUser").connect("text_changed",self,"teste")

	
func _button_baseMemoria_pressed(value):
	pass

func _button_continuar_pressed():
	if get_node("nomeUser").get_text() != "": 
		globalConfig.set_playerName(get_node("nomeUser").get_text())
		print(get_node("nomeUser").get_text())
		if choosed: globalScript.goToScene(cena)
	
func _quit():
	globalScript.quit()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	globalScript = get_node("/root/globalScript")
	globalConfig = get_node("/root/globalConfig")
	get_node("b_jogoGoleiro").connect("pressed",self,"_button_jogoGoleiro_pressed")
	get_node("b_continuar").connect("pressed",self,"_button_continuar_pressed")
	get_node("b_sair").connect("pressed",self,"_quit")
	get_node("b_sair").connect("pressed",self,"_quit")
	
	get_node("nomeUser").hide()

	#get_node("b_continuar").hide()

func _process(delta):
	if Input.is_action_pressed("ui_enter_name") && choosed  && cena != "": _button_continuar_pressed()

func _on_nomeUser_text_changed( text ):
	# Aqui vai ficar a checagem do texto que será digitado no campo "nome"
	var avoidChars  = "#<$+%>!`&*\'|{?\"=}/:\\@"
	var size = text.length()
	if size > 0:
		for i in avoidChars:
			if text[size-1] == i:
				text = text.substr(0,size-1)
				get_node("nomeUser").set_text(text)
				get_node("nomeUser").set_cursor_pos(size-1)
				break;

	if text.length() > 15 : 
		text = text.substr(0,15)
		get_node("nomeUser").set_text(text)
		get_node("nomeUser").set_cursor_pos(15)
