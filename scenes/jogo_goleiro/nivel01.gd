extends Node2D
var root
var qntChutes = 10
var lockInput = false
var timeLock = 0
var defenseSeq = ""
var kickSeq 
var timeHide = 0.5
var numGols = 0
var numDefenses = 0
var numKicks = 0

var tree = {
	"00":[0,1,0],
	"10":[0,0,1],
	"20":[1,0,0],
	"1":[.7,0,.3],
	"02":[0,0,1],
	"12":[1,0,0],
	"22":[0,1,0]
}

func _button_voltaMenu_pressed():
	root.goToScene("res://scenes/GUI/choose_game/choose_game.tscn")
	
func _button_nextLvl_pressed():
	root.goToScene("res://scenes/jogo_goleiro/nivel02.tscn")
	
func _button_fimJogo_pressed():
	get_node("janelaFim").show()
	get_node("b_endGame").hide()
	get_node("janelaSequencia").hide()
	get_node("JanelaTeste").hide()
	get_node("janelaPlacar").hide()

func _resultKick():
	numKicks += 1
	if defenseSeq[numKicks-1] == kickSeq[numKicks-1]: 
		get_node("JanelaTeste/l_result").set_text("Defendeu")
		numDefenses += 1
	else:
		get_node("JanelaTeste/l_result").set_text("Gol")
		numGols += 1

	"""
	EStá dando algum problema com o uso da diretiva 'match'...
	Não sei porque. Utilizei o 'if' grosseiramente mesmo.
	
	match defenseSeq[tam-1]:
		0:	print("test 0")
		1:	print("test 0")
	"""
	
	if defenseSeq[numKicks-1] == '0': get_node("JanelaTeste/l_goleiro").set_text("Esquerda")
	if defenseSeq[numKicks-1] == '1': get_node("JanelaTeste/l_goleiro").set_text("Centro")
	if defenseSeq[numKicks-1] == '2': get_node("JanelaTeste/l_goleiro").set_text("Direita")
	if kickSeq[numKicks-1] == '0': get_node("JanelaTeste/l_chute").set_text("Esquerda")
	if kickSeq[numKicks-1] == '1': get_node("JanelaTeste/l_chute").set_text("Centro")
	if kickSeq[numKicks-1] == '2': get_node("JanelaTeste/l_chute").set_text("Direita")
	
func _button_kick_pressed(kick):
	get_node("b_chutes").hide()
	lockInput = true
	defenseSeq += kick
	_resultKick()

	
func _updatePlacar():
	get_node("janelaPlacar/l_numGols").set_text(str(numGols))
	get_node("janelaPlacar/l_numDefensas").set_text(str(numDefenses))
	get_node("janelaPlacar/l_numTotal").set_text(str(numKicks))

func _quit():
	root.quit()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	root = get_node("/root/globalScript")
	get_node("b_endGame").connect("pressed",self,"_button_fimJogo_pressed")
	get_node("janelaFim/b_voltaMenu").connect("pressed",self,"_button_voltaMenu_pressed")
	get_node("janelaFim/b_nextLvl").connect("pressed",self,"_button_nextLvl_pressed")
	get_node("janelaFim/b_sairGame").connect("pressed",self,"_quit")
	get_node("b_chutes/b_baixo").connect("pressed",self,"_button_kick_pressed",["1"])
	get_node("b_chutes/b_esquerda").connect("pressed",self,"_button_kick_pressed",["0"])
	get_node("b_chutes/b_direita").connect("pressed",self,"_button_kick_pressed",["2"])
	get_node("janelaFim").hide()
	kickSeq = root.genSeq(qntChutes,tree)
	get_node("janelaPlacar/l_numTotalChutes").set_text(str(qntChutes))
	#OS.set_window_fullscreen(false)
	
func _process(delta):
	var strPrintada = "Total de chutes: " +  str(qntChutes) + "\nSequência:\n" + kickSeq + "\nDefesas:\n" + defenseSeq
	get_node("janelaSequencia/showSequence").set_text(strPrintada)
	if qntChutes == defenseSeq.length() :
		delta =  0
		# somente para não aparecer novamente os botões dos próximos chutes.
		# Depois podemos refazer.
	
	# a variável lockInput é para evitar que o usuário "segure para baixo" e receba vários chutes para baixo e assim para as laterais
	if lockInput == true:
		timeLock += delta
		if timeLock > timeHide :
			timeLock = 0
			lockInput = false
			get_node("b_chutes").show()

	if Input.is_action_pressed("ui_down") && !lockInput: _button_kick_pressed("1")
	if Input.is_action_pressed("ui_left") && !lockInput: _button_kick_pressed("0")
	if Input.is_action_pressed("ui_right") && !lockInput: _button_kick_pressed("2")
	_updatePlacar()
