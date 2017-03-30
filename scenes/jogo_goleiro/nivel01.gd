extends Node2D
var globalScript
var qntChutes = 0
var lockInput = false
var timeLock = 0
var defenseSeq = ""
var kickSeq 
var timeHide = 2
var animSpeed = 1
var numGols = 0
var numDefenses = 0
var numKicks = 0
var anim = {}
var timeControlAnim =0
var savedGame = false
var defense = {"0":"Defendeu-Esquerda", "1":"Defendeu-Meio", "2":"Defendeu-Direita"}
var goal = {"0":"Errou-Esquerda", "1":"Errou-Meio", "2":"Errou-Direita"}
var tree = {
	"00":[0,1,0],
	"10":[0,0,1],
	"20":[1,0,0],
	"1":[.7,0,.3],
	"02":[0,0,1],
	"12":[1,0,0],
	"22":[0,1,0]
}
var globalTime = 0
var lastRecordedTime = 0
var historicPlays = ""
var time = 0
const animGoalKepper = "goalKeeper/Goleiro/Animação-Goleiro"
const animKicker = "Kicker/Cobrador/AnimationPlayer"
const animBall = "ball/Bola/Sprite/AnimationPlayer"

func _button_voltaMenu_pressed():
	globalScript.goToScene("res://scenes/GUI/choose_game/choose_game.tscn")
	
func _button_nextLvl_pressed():
	#globalScript.goToScene("res://scenes/jogo_goleiro/nivel02.tscn")
	pass
	
func _button_fimJogo_pressed(callMode):
	get_node("janelaFim").show()
	get_node("b_endGame").hide()
	get_node("janelaSequencia").hide()
	saveData(callMode)

func _resultKick():
	var chutes = {"0":"Esquerda", "1":"Centro", "2":"Direita"}
	numKicks += 1
	historicPlays += kickSeq[numKicks-1] + ","
	historicPlays += defenseSeq[numKicks-1]+ ","
	
	if defenseSeq[numKicks-1] == kickSeq[numKicks-1]: 
		get_node("Label").set_text("Defendeu")
		numDefenses += 1
		historicPlays += "True,"
	else:
		get_node("Label").set_text("Perdeu")
		numGols += 1
		historicPlays += "False,"
	historicPlays += str(globalTime - lastRecordedTime) + ",-----\n"
	lastRecordedTime = globalTime
	print(historicPlays)

func _button_kick_pressed(kick):
	get_node("b_chutes").hide()
	lockInput = true
	defenseSeq += kick
	get_node(animKicker).play("Cobrador")
	_resultKick()

func animFlow():
	# This function control animations and return if animations finished or nor.
	if get_node(animKicker).is_playing() && !get_node(animGoalKepper).is_playing() && !get_node(animBall).is_playing():
		if get_node(animKicker).get_current_animation_pos() >= 0.99:
			if defenseSeq[numKicks-1] == kickSeq[numKicks-1]: 
				get_node(animGoalKepper).play(defense[defenseSeq[numKicks-1]])
				get_node(animBall).play(defense[defenseSeq[numKicks-1]])
			else:
				get_node(animGoalKepper).play(goal[defenseSeq[numKicks-1]])
				get_node(animBall).play(goal[kickSeq[numKicks-1]])

	if !get_node(animGoalKepper).is_playing() && !get_node(animKicker).is_playing() && !get_node(animBall).is_playing(): return false
	else: return true
	
func _updatePlacar():
	get_node("scoreboard").change(int(numGols),int(numDefenses))

func _quit():
	globalScript.quit()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	globalScript = get_node("/root/globalScript")
	globalConfig = get_node("/root/globalConfig")
	globalServer = get_node("/root/globalServer")

	# Temporário só para fazer os testes...
	globalConfig.loadPacketConfFiles("user://packets/Pacote1")

	tree = globalConfig.get_tree(0)
	qntChutes =  globalConfig.get_qntChutes(0)
	kickSeq = globalScript.genSeq(qntChutes,tree)

	get_node("b_endGame").connect("pressed",self,"_button_fimJogo_pressed",["INTERRUPTED BY USER"])
	get_node("janelaFim/b_voltaMenu").connect("pressed",self,"_button_voltaMenu_pressed")
	get_node("janelaFim/b_nextLvl").connect("pressed",self,"_button_nextLvl_pressed")
	get_node("janelaFim/b_sairGame").connect("pressed",self,"_quit")
	get_node("b_chutes/b_baixo").connect("pressed",self,"_button_kick_pressed",["1"])
	get_node("b_chutes/b_esquerda").connect("pressed",self,"_button_kick_pressed",["0"])
	get_node("b_chutes/b_direita").connect("pressed",self,"_button_kick_pressed",["2"])
	get_node("janelaFim").hide()
	get_node(animGoalKepper).set_speed(animSpeed)
	get_node(animKicker).set_speed(animSpeed)
	get_node(animBall).set_speed(animSpeed)
	#OS.set_window_fullscreen(true)
	
func _process(delta):
	globalTime += delta
	timeControlAnim += delta
	var stringDebug  = "Total de chutes: " +  str(qntChutes) + "\nSequência:\n" + kickSeq + "\nDefesas:\n" + defenseSeq + "\nTree:\n" + str(tree)
	get_node("janelaSequencia/showSequence").set_text(str(stringDebug))

	# a variável lockInput é para travar as setas de chute
	if lockInput == true:
		if !animFlow():
			get_node(animGoalKepper).seek(0,true)
			get_node(animBall).seek(0,true)
			get_node(animKicker).seek(0,true)
			# We achieve the maximum number of defense. Stop the "process" mode.
			_updatePlacar()
			if qntChutes == defenseSeq.length():
				globalServer.connect()
				set_process(false)
				_button_fimJogo_pressed("OK")
			else:
				lockInput = false 
				lastRecordedTime = globalTime
				get_node("Label").set_text("")
				get_node("b_chutes").show()

	if Input.is_action_pressed("ui_down") && !lockInput: _button_kick_pressed("1")
	if Input.is_action_pressed("ui_left") && !lockInput: _button_kick_pressed("0")
	if Input.is_action_pressed("ui_right") && !lockInput: _button_kick_pressed("2")
	if Input.is_action_pressed("ui_quit"): saveData("INTERRUPTED BY USER")
	
func saveData(callMode):
	#var teste = historicPlays.split("\n")
	#for line in teste:
	#	print (line)
	
	if savedGame == false:
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
		if numKicks == 0 : strData += "successRate,*** >-------<\n"
		else: strData += "successRate,*** >"+str(numDefenses/numKicks)+"<\n"
		strData += "minHits, ?????\n"
		strData += "gameMode," + globalConfig.get_seqMode(0) + "\n"
		strData += "status," + str(callMode) + "\n"
		strData += "waitedResult,optionChosen,correct,movementTime,decisionTime\n"
		strData += historicPlays + "TOTAL_TIME: "+ str(globalTime)
		
		var playerName = globalConfig.get_playerName()
		var restrictFileName = changeFileName(playerName)
		fileName += "Plays_JG_" +  globalConfig.get_id(0)+ "_"+restrictFileName+"_"+strDateTime+"_"+randomFlag
		var file = File.new()
		var dir = Directory.new()
		if ! dir.dir_exists ("user://toSend/"): dir.make_dir("user://toSend/")
		var inteiro = file.open("user://toSend/"+fileName+".csv",File.WRITE)
		file.store_string(strData)
		file.close()
		savedGame= true
	
func changeFileName(fileName):
	var avoidChars  = "#<$+%>!`&*\'|{?\"=}/:\\ @"
	for i in avoidChars: 
		for j in range(fileName.length()):
			if fileName[j] == i: fileName[j] = "X"
	return fileName
	
	