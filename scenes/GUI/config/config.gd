extends Node

var root


func _button_avancar_pressed():
	root.goToScene("res://scenes/GUI/choose_game/choose_game.tscn")

func _button_loadPackage_pressed(teste):
	print(teste)
#	get_node("/root/globalScript").loadPackge(teste)

func sair():
	root.quit()
	
func loadPacketNames():
	var dir = Directory.new()
	var dicPackets = {}
	# abrir o diretorio user:// onde estao os pacotes
	if  dir.open( "user://packets" ) == OK:
		# e encontrar todos os pacotes disponiveis no diretorio
		dir.list_dir_begin()
		var fileName = dir.get_next()
		while (fileName != ""):
			if (fileName == "." || fileName == ".."):
				fileName = dir.get_next()
				continue
			if dir.current_is_dir():
				# encontrado um diretorio de pacotes
				dicPackets[fileName] = dir.get_current_dir() + "/" + fileName
				fileName = dir.get_next()
			else:
				# se nao existe o diretorio, gravar no log
				print("Erro: nÃ£o   existe o diretÃ³rio packets em ", OS.get_data_dir())
		if dicPackets.size() == 0:
			print("Erro: nÃ£o existem pacotes no diretü…µ³ Ã³rio ", OS.get_data_dir())
	return dicPackets

func _ready():
	var packets = loadPacketNames()
	var buttonSize = 55
	var pos_y = 80
	# Called every time the node is added to the scene.
	# Initialization here
	#set_process(true)
	if packets.size() > 0:
		var i = 0
		# Inicialmente sÃ³ iremos apresentar os 9 primeiros pacotes,
		#depois podemos pensar em algo mais elaborado
		if packets.size() < 9 : pos_y = pos_y + (get_node("Panel").get_size().y - pos_y - packets.size()*buttonSize)/2
		for key in packets:
			if i > 8 : break
			pos_y = createButton(key,pos_y,packets[key])
			i += 1
			

	root = get_node("/root/globalScript")
	get_node("avancar").connect("pressed",self,"_button_avancar_pressed")
	get_node("sair").connect("pressed",self,"sair")
	#OS.set_window_fullscreen(true)

#func _process(delta):
	
func createButton(label,pos_y,fileName):
	var texture = ImageTexture.new()
	var novo = TextureButton.new()
	var texto = Label.new()
	var pai = get_node("Panel")
	var scale_x = 0.85
	var scale_y = 0.25
	texture.load("res://images/Interface/button.png")
	novo.set_normal_texture(texture)
	texto.set_theme(load("res://themes/listButtons.tres"))

	pai.add_child(novo)
	novo.add_child(texto)
	texto.set_text(label)
	texto.set_autowrap(true)
	novo.set_normal_texture(texture)
	novo.set_scale(Vector2(scale_x,scale_y))
	texto.set_pos(Vector2(0,0))

	texto.set_scale(Vector2(1/novo.get_scale().x,1/novo.get_scale().y))
	texto.set_size(Vector2(novo.get_size().x*scale_x,novo.get_size().y*scale_y))
	texto.set_valign(Label.VALIGN_CENTER)
	texto.set_align(Label.ALIGN_CENTER)
	var pos_x = (pai.get_size().x - scale_x*novo.get_size().x)/2

	novo.set_pos(Vector2(pos_x,pos_y))
	novo.connect("pressed",self,"_button_loadPackage_pressed",[fileName])
	return novo.get_size().y*scale_y+pos_y
	