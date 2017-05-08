extends TextureFrame

var globalScript
var globalConfig
var choosed = false
var cena = ""
var menu = []

func _button_game_pressed(buttonNumber):
	choosed = true;

	cena = globalConfig.get_scene(menu[buttonNumber]["gameID"])

	get_node("b_game0").hide()
	get_node("b_game1").hide()
	get_node("b_game2").hide()
	get_node("b_game3").hide()
	get_node("b_game4").hide()
	get_node("b_game5").hide()

	
	get_node("b_sair").hide()
	get_node("description").set_text(menu[buttonNumber]["title"])
	get_node("description").set_align(Label.ALIGN_CENTER)
	get_node("nomeUser").show()
	get_node("b_continuar").show()
	get_node("nomeUser").grab_focus()
	get_node("b_menu_game").show()
	get_node("name_descrition").show()

func _button_continuar_pressed():
	if get_node("nomeUser").get_text() != "": 
		globalConfig.set_playerName(get_node("nomeUser").get_text())
		if choosed && cena != "": 
			globalScript.currentLevel = 0
			globalScript.goToScene(cena)
		
func _button_b_menu_game_pressed():
	choosed = false
	cena = ""
	
	for i in range (0,menu.size()):
		get_node("b_game"+str(5-i)).show()
		if i > 5: break

	get_node("b_sair").show()
	get_node("description").set_text("Você é um goleiro na hora do pênalti e deve decidir para onde pular (esquerda, direita ou centro) antes da bola sair. Atenção: cada batedor tem um estratégia própria  para escolher onde vai chutar. Mas cuidado, ele pode tentar te enganar!")
	get_node("description").set_align(Label.ALIGN_FILL)
	get_node("nomeUser").hide()
	get_node("b_continuar").hide()
	get_node("b_menu_game").hide()
	get_node("name_descrition").hide()
	pass

func _quit():
	globalScript.quit()

func _ready():

	set_process(true)
	globalScript = get_node("/root/globalScript")
	globalConfig = get_node("/root/globalConfig")
	menu = globalConfig.get_menu()
	
	var aux = 6-menu.size()
	print(aux)
	for i in range (0,menu.size()):
		get_node("b_game"+str(i+aux)).connect("pressed",self,"_button_game_pressed",[i])
		get_node("b_game"+str(i+aux)+"/Label").set_text(menu[i]["title"])
		if i > 6: break
	for i in range (0,aux):
		get_node("b_game"+str(i)).hide()
		
	#get_node("b_game06").connect("pressed",self,"_button_game_pressed",[5])
	get_node("b_continuar").connect("pressed",self,"_button_continuar_pressed")
	get_node("b_sair").connect("pressed",self,"_quit")
	get_node("b_menu_game").connect("pressed",self,"_button_b_menu_game_pressed")
	
	get_node("nomeUser").hide()


func _process(delta):
	if Input.is_action_pressed("ui_enter_name") && choosed  && cena != "": _button_continuar_pressed()

func _on_nomeUser_text_changed( text ):
	# Aqui vai é a checagem em tempo real
	# do texto que será digitado no campo "nome"
	# Basicamente testamos o último caractere.
	# Se for proibido, então retira.

	var avoidChars  = globalScript.get_avoidChars()
	var size = text.length()
	
	# Checking avoid characteres
	if size > 0:
		for i in avoidChars:
			if text[size-1] == i:
				text = text.substr(0,size-1)
				get_node("nomeUser").set_text(text)
				get_node("nomeUser").set_cursor_pos(size-1)
				break;
	
	# Checking the size of string
	if text.length() > 15 : 
		text = text.substr(0,15)
		get_node("nomeUser").set_text(text)
		get_node("nomeUser").set_cursor_pos(15)
