extends Node2D
var globalScript
var qntChutes = 0
var lockInput = false
var timeLock = 0
var defenseSeq = ""
var kickSeq 
var timeHide = 2
var animSpeed = 5
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
var time = 0
var historicPlays = ""

func _button_voltaMenu_pressed():
	globalScript.goToScene("res://scenes/GUI/choose_game/choose_game.tscn")
	
func _button_nextLvl_pressed():
	#globalScript.goToScene("res://scenes/jogo_goleiro/nivel02.tscn")
	pass
	
func _button_fimJogo_pressed():
	get_node("janelaFim").show()
	get_node("b_endGame").hide()
	get_node("janelaSequencia").hide()
	get_node("JanelaTeste").hide()
	get_node("janelaPlacar").hide()

func _resultKick():
	var chutes = {"0":"Esquerda", "1":"Centro", "2":"Direita"}
	numKicks += 1
	historicPlays += kickSeq[numKicks-1] + ","
	historicPlays += defenseSeq[numKicks-1]+ ","
	
	if defenseSeq[numKicks-1] == kickSeq[numKicks-1]: 
		get_node("JanelaTeste/l_result").set_text("Defendeu")
		numDefenses += 1
		historicPlays += "True,"

	else:
		get_node("JanelaTeste/l_result").set_text("Gol")
		numGols += 1
		historicPlays += "False,"
	historicPlays += str(time) + ",-----\n"
	
	get_node("JanelaTeste/l_goleiro").set_text(chutes[defenseSeq[numKicks-1]])
	get_node("JanelaTeste/l_chute").set_text(chutes[kickSeq[numKicks-1]])
	
func _button_kick_pressed(kick):
	var defesas = {"0":"Defendeu-Esquerda", "1":"Defendeu-Meio", "2":"Defendeu-Direita"}
	get_node("b_chutes").hide()
	lockInput = true
	get_node("goalKeeper/Animação").play(defesas[kick])
	defenseSeq += kick
	_resultKick()

func _updatePlacar():
	get_node("janelaPlacar/l_numGols").set_text(str(numGols))
	get_node("janelaPlacar/l_numDefensas").set_text(str(numDefenses))
	get_node("janelaPlacar/l_numTotal").set_text(str(numKicks))

func _quit():
	globalScript.quit()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	globalScript = get_node("/root/globalScript")
	globalConfig = get_node("/root/globalConfig")
	
	# Temporário só para fazer os testes...
	globalConfig.loadPacketConfFiles("user://packets/Pacote1")

	tree = globalConfig.get_tree(0)
	qntChutes =  globalConfig.get_qntChutes(0)
	kickSeq = globalScript.genSeq(qntChutes,tree)

	get_node("b_endGame").connect("pressed",self,"_button_fimJogo_pressed")
	get_node("janelaFim/b_voltaMenu").connect("pressed",self,"_button_voltaMenu_pressed")
	get_node("janelaFim/b_nextLvl").connect("pressed",self,"_button_nextLvl_pressed")
	get_node("janelaFim/b_sairGame").connect("pressed",self,"_quit")
	get_node("b_chutes/b_baixo").connect("pressed",self,"_button_kick_pressed",["1"])
	get_node("b_chutes/b_esquerda").connect("pressed",self,"_button_kick_pressed",["0"])
	get_node("b_chutes/b_direita").connect("pressed",self,"_button_kick_pressed",["2"])
	get_node("janelaFim").hide()
	get_node("goalKeeper/Animação").set_speed(animSpeed)
	get_node("janelaPlacar/l_numTotalChutes").set_text(str(qntChutes))
	#OS.set_window_fullscreen(true)
	
func _process(delta):
	time += delta
	var stringDebug  = "Total de chutes: " +  str(qntChutes) + "\nSequência:\n" + kickSeq + "\nDefesas:\n" + defenseSeq + "\nTree:\n" + str(tree)
	get_node("janelaSequencia/showSequence").set_text(str(stringDebug))

	# a variável lockInput é para travar as setas de chute
	if lockInput == true:
		if !get_node("goalKeeper/Animação").is_playing() :
			get_node("goalKeeper/Animação").seek(0,true)
			# We achieve the maximum number of defense. Stop the "process" mode.
			if qntChutes == defenseSeq.length():
				saveData("OK")
				set_process(false)
				_button_fimJogo_pressed()
			else:
				lockInput = false
				get_node("b_chutes").show()
				time = 0

	if Input.is_action_pressed("ui_down") && !lockInput: _button_kick_pressed("1")
	if Input.is_action_pressed("ui_left") && !lockInput: _button_kick_pressed("0")
	if Input.is_action_pressed("ui_right") && !lockInput: _button_kick_pressed("2")
	_updatePlacar()

func saveData(callMode):
	var dateTime = OS.get_datetime()
	var strDateTime = ""
	var fileName = ""
	randomize()
	var randomFlag = str(round(rand_range(0,999)))
	strDateTime = str(dateTime.year)+str(dateTime.month)+str(dateTime.day)+"_"
	strDateTime += str(dateTime.hour)+str(dateTime.minute)+str(dateTime.second)
	
	var strData = "game,_JG_\n"
	strData += "playId," + globalConfig.get_id(0) + "\n"
	strData += "playerAlias," + globalConfig.get_playerName() + ",HP-HP_"+strDateTime+"_" + randomFlag + "\n"
	strData += "totalPlays,"+ str(numKicks) + "\n"
	strData += "totalCorrect,"+ str(numDefenses) + "\n"
	strData += "successRate,*** >"+str(numDefenses/numKicks)+"<\n"
	strData += "minHits, ?????\n"
	strData += "gameMode," + globalConfig.get_seqMode(0) + "\n"
	strData += "status," + str(callMode) + "\n"
	strData += "waitedResult,optionChosen,correct,movementTime,decisionTime\n"
	strData += historicPlays
	
	fileName += "Plays_JG_" +  globalConfig.get_id(0)+ "_"+globalConfig.get_playerName()+"_"+strDateTime+"_"+randomFlag
	var file = File.new()
	file.open("user://"+fileName+".csv",File.WRITE)
	file.store_string(strData)
	file.close()