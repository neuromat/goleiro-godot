extends Node

var root
var error = [false,0] # Some error happened, so we need stop program. Second coordinate represents the erro number


func _button_avancar_pressed():
	root.goToScene("res://scenes/GUI/choose_game/choose_game.tscn")

func _button_loadPackage_pressed(pathDir):
	var strPackage = ""
	error = [false,0]
	strPackage = "Carregando o pacote: " + pathDir
	if(globalConfig.loadPacketConfFiles(pathDir) != OK):
		get_node("Log_packets").set_text("\nError no carregamento do arquivo")
		error = [true,1]
		return !OK
	for i in range(0,globalConfig.level.size()):
		if !globalConfig.level[i].has("limitPlays"):
			error = [true,0]
			strPackage += "\nError fase "+str(i)+", ausência de campo \"limitPlays\" "
		if !globalConfig.level[i].has("readSequ"):
			error = [true,0]
			strPackage += "\nError fase "+str(i)+", ausência de campo \"readSeq\" "
		elif globalConfig.level[i]["readSequ"] == "false" && !globalConfig.level[i].has("tree"):
				error = [true,0]
				strPackage += "\nError fase "+str(i)+", ausência de campo \"tree\" "
		elif globalConfig.level[i]["readSequ"] == "true" && !globalConfig.level[i].has("sequ"):
			error = [true,0]
			strPackage += "\nError fase "+str(i)+", ausência de campo \"seque\" "
			
		if globalConfig.level[i]["readSequ"] == "false" && globalConfig.get_tree(i) == null:
			error = [true,0]
			strPackage += "\nError fase "+str(i)+", leitura da árvore"
	if error[0]: 
		get_node("b_avancar").hide()
	else:
		strPackage += "\nCarregado..."
		get_node("b_avancar").show()
	get_node("Log_packets").set_text(strPackage)
	return OK

func sair():
	root.quit()


func _ready():
	
	var packets 
	var buttonSize = 55
	var pos_y = 80
	
	root = get_node("/root/globalScript")
	globalConfig = get_node("/root/globalConfig")
	
	packets = globalConfig.loadPacketNames()
	# Called every time the node is added to the scene.
	# Initialization here
	#set_process(true)
	if packets.size() > 0:
		var i = 0
		# At this momment, we show the first nine packages
		if packets.size() < 9 : pos_y = pos_y + (get_node("Panel").get_size().y - pos_y - packets.size()*buttonSize)/2
		for key in packets:
			if i > 8 : break
			pos_y = createButton(key,pos_y,packets[key])
			i += 1
			
	get_node("b_avancar").connect("pressed",self,"_button_avancar_pressed")
	get_node("b_avancar").hide()
	get_node("b_sair").connect("pressed",self,"sair")
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
	