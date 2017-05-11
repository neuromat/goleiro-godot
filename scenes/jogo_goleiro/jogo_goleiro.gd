extends Node2D
var fase = 0
var globalScript
var qntChutes = 0
var lockInput = false
var timeLock = 0
var interval = 0
var lockInterval = false
var lockAnimationPhrase = false # locker for phrase animation
var defenseSeq = ""
var kickSeq = ""
var timeHide = 2
var animSpeed = 1
var numGols = 0
var numDefenses = 0
var numKicks = 0
var anim = {}
var timeControlAnim =0
var sequR = "" # Sequência que informa se o chute foi de uma escolha aleatória ou não
var savedGame = false
var defense = {"0":"Defendeu-Esquerda", "1":"Defendeu-Meio", "2":"Defendeu-Direita"}
var goal = {"0":"Errou-Esquerda", "1":"Errou-Meio", "2":"Errou-Direita"}
var globalTime = 0
var lastRecordedTime = 0
var historicPlays = ""
const animGoalKepper = "goalKeeper/Goleiro/Animação-Goleiro"
const animKicker = "Kicker/Cobrador/AnimationPlayer"
const animBall = "ball/Bola/Sprite/AnimationPlayer"

func _button_nextLvl_pressed():
	var nextScene = ""
	var nextSceneDic = {}
	if globalScript.get_currentLevel() == globalConfig.get_numLvls()-1:
		# We played all phases
		nextScene = "res://scenes/GUI/choose_game/choose_game.tscn"
		globalScript.currentLevel = 0
		globalScript.goToScene(nextScene)
		return
	if fase > 3:
		# After phase 3, all scenes will use lvl3 pattern
		nextScene = "res://scenes/jogo_goleiro/nivel3.tscn"
		globalScript.currentLevel += 1
		globalScript.goToScene(nextScene)
		return
	if globalConfig.has_phaseZero(): nextSceneDic = {0:"1", 1:"1", 2:"2",3:"3",4:"3"}
	else: nextSceneDic = {0:"1", 1:"2", 2:"3",3:"3",4:"3"}
	nextScene = "res://scenes/jogo_goleiro/nivel"+nextSceneDic[fase+1]+".tscn"
	globalScript.currentLevel += 1
	globalScript.goToScene(nextScene)

func _button_fimJogo_pressed(callMode):
	get_node("janelaFim").show()
	if globalScript.get_currentLevel() == globalConfig.get_numLvls()-1:
		# Finalizada as fases
		get_node("janelaFim/b_nextLvl/Label").set_text("Menu de\njogos")
	else:
		# Ainda tem mais fases para serem jogadas
		get_node("janelaFim/b_nextLvl/Label").set_text("Avançar")
	get_node("b_endGame").hide()
	
	# Dependendo do arquivo de configuração, se o parâmetro
	# "finalScoreboard" for none, short ou long, então a
	# fase deve aparecer de maneira diferenciada
	var phrase = ""
	var rate =0.0
	if numKicks != 0 : rate = float(numDefenses)/float(numKicks)
	if globalConfig.get_finalScoreboard(fase) == "none" : phrase = "Jogo do Goleiro Fase "+str(fase)
	elif globalConfig.get_finalScoreboard(fase) == "short" : phrase = "Jogo do Goleiro "+str(fase)+"\n"+str(numDefenses)+"/"+str(numKicks)
	else: phrase = "Jogo do Goleiro "+str(fase)+"\n"+str(numDefenses)+" defesas em "+str(numKicks)+" chutes ("+str(rate)+"%)"
	get_node("janelaFim/scoreBoard").set_text(phrase)
	saveData(callMode)

func _resultKick():
	numKicks += 1
	historicPlays += kickSeq[numKicks-1] + ","+sequR[numKicks-1]+"," +defenseSeq[numKicks-1]+ ","
	if defenseSeq[numKicks-1] == kickSeq[numKicks-1]: 
		numDefenses += 1
		historicPlays += "True,"
	else:
		numGols += 1
		historicPlays += "False,"
	historicPlays += str(globalTime - lastRecordedTime) + "\n"
	lastRecordedTime = globalTime

func _button_kick_pressed(kick):
	if interval >0 : interval = interval - 1
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
	if get_node(animGoalKepper).is_playing() && get_node(animKicker).get_current_animation_pos() >= 0.75:
		# The variable "animationPhrase" lock or unlock the phrase animation 
		if !lockAnimationPhrase:
			if defenseSeq[numKicks-1] == kickSeq[numKicks-1]: get_node("phrase/AnimationPlayer").play("defendeu")
			else: get_node("phrase/AnimationPlayer").play("perdeu")
		
	if !get_node(animGoalKepper).is_playing() && !get_node(animKicker).is_playing() && !get_node(animBall).is_playing() && !get_node("phrase/AnimationPlayer").is_playing(): return false
	else: return true
	
func _updatePlacar():
	get_node("scoreboard").change(int(numGols),int(numDefenses))

func _quit():
	globalScript.quit()

func _ready():
	globalScript = get_node("/root/globalScript")
	globalConfig = get_node("/root/globalConfig")
	globalServer = get_node("/root/globalServer")
	fase = globalScript.get_currentLevel()

	
	# Temporário só para fazer os testes...
	globalConfig.loadPacketConfFiles("user://packets/default")

	#Gerando a sequência de chutes e de aleatoriedade
	kickSeq = globalConfig.get_sequ(fase)
	sequR = globalConfig.get_sequR(fase)
	qntChutes =  globalConfig.get_qntChutes(fase)
	interval = globalConfig.get_playsToRelax(fase)

	get_node("b_endGame").connect("pressed",self,"_button_fimJogo_pressed",["INTERRUPTED BY USER"])
	get_node("janelaFim/b_nextLvl").connect("pressed",self,"_button_nextLvl_pressed")
	get_node("janelaFim/b_sairGame").connect("pressed",self,"_quit")
	get_node("b_chutes/b_baixo").connect("pressed",self,"_button_kick_pressed",["1"])
	get_node("b_chutes/b_esquerda").connect("pressed",self,"_button_kick_pressed",["0"])
	get_node("b_chutes/b_direita").connect("pressed",self,"_button_kick_pressed",["2"])
	get_node("janelaFim").hide()
	if !globalConfig.has_scoreboard(fase):
		get_node("historic_plays").hide()
		get_node("scoreboard").hide()

	get_node("janelaFim/nome").set_text(globalConfig.get_playerName().to_upper())
	get_node(animGoalKepper).set_speed(animSpeed)
	get_node(animKicker).set_speed(animSpeed)
	get_node(animBall).set_speed(animSpeed)
	if globalConfig.get_animationTypeJG(fase) == "long": get_node("phrase/AnimationPlayer").set_speed(0.5)
	elif globalConfig.get_animationTypeJG(fase) == "short": get_node("phrase/AnimationPlayer").set_speed(1.0)
	else: lockAnimationPhrase = true
	
	set_process(true)
	
func _input(event):
	if Input.is_action_pressed("ui_space"): _unlockInterval()

func _unlockInterval():
	interval = globalConfig.get_playsToRelax(fase)
	get_node("interval").hide()
	set_process(true)
	set_process_input(false)

func _lockInterval():
	if interval == 0:
		get_node("interval").show()
		set_process(false)
		set_process_input(true)

func _process(delta):
	globalTime += delta
	timeControlAnim += delta

	# a variável lockInput é a trava para as setas de chute
	if lockInput == true:
		if !animFlow():
			get_node(animGoalKepper).seek(0,true)
			get_node(animBall).seek(0,true)
			get_node(animKicker).seek(0,true)
			_updatePlacar()
			get_node("historic_plays").updateHistoric(defenseSeq,kickSeq)
			if globalConfig.get_playsToRelax(fase) > 0: _lockInterval()
			# We achieve the maximum number of defense. Stop the "process" mode.
			if qntChutes == defenseSeq.length():
				globalServer.connect()
				set_process(false)
				_button_fimJogo_pressed("OK")
			else:
				lockInput = false 
				lastRecordedTime = globalTime
				get_node("b_chutes").show()

	if Input.is_action_pressed("ui_down") && !lockInput: _button_kick_pressed("1")
	if Input.is_action_pressed("ui_left") && !lockInput: _button_kick_pressed("0")
	if Input.is_action_pressed("ui_right") && !lockInput: _button_kick_pressed("2")
	if Input.is_action_pressed("ui_quit"): saveData("INTERRUPTED BY USER")
	
func saveData(callMode):
	if savedGame == false:
		var dateTime = OS.get_datetime()
		var strDateTime = ""
		var fileName = ""
		var rate = 0.0
		var randomFlagStr = ""
		var strData = "experimentGroup,game,playID,phase,gameTime,relaxTime,playerMachine,YYMMDD,HHMMSS,random,playerAlias,limitPlays,totalCorrect,successRate,gameMode,status,playsToRelax,scoreboard,finalScoreboard,animationType,move,waitedResult,ehRandom,optionChosen,correct,movementTime\n"
		var strCommonData = ""
		if numKicks != 0 : rate = float(numDefenses)/float(numKicks)
		randomize()
		randomFlagStr = "%03d" % round(rand_range(0,999))
		strDateTime = "%02d%02d%02d,%02d%02d%02d,%s" % [dateTime.year%100, dateTime.month, dateTime.day,dateTime.hour,dateTime.minute,dateTime.second,randomFlagStr]
		
		strCommonData += globalConfig.get_packName() + ",JG,"+ globalConfig.get_id(fase)+",ph1,"+str(globalTime)+",0,XX-XX,"+strDateTime+","
		strCommonData += globalConfig.get_playerName()+","+ str(numKicks)+","+str(numDefenses)+","+str(rate)+","
		strCommonData += globalConfig.get_seqMode(fase)+","+str(callMode)+","+str(globalConfig.get_playsToRelax(fase))+","+globalConfig.get_scoreboard(fase)+","
		strCommonData += globalConfig.get_finalScoreboard(fase)+","+globalConfig.get_animationTypeJG(fase)+","

		var historicPlaysArray = historicPlays.split("\n")
		for line in range(0,historicPlaysArray.size()-1):
			strData += strCommonData + str(line+1) +","+ historicPlaysArray[line]+"\n"

		# Making context tree string
		var tree = globalConfig.get_tree(fase)
		var tree_string = "tree: "
		for i in tree.keys():
			tree_string += str(i) + ": "
			for j in tree[i]:
				tree_string += str(tree[i][j]) + ","
			tree_string[tree_string.length()-1] = " "
			tree_string += "|"
		tree_string[tree_string.length()-1] = " "

		# Making context tree string
		var tree = globalConfig.get_tree(fase)
		var tree_string = "tree: "
		for i in tree.keys():
			tree_string += str(i) + ": "
			for j in range(0,tree[i].size()):
				tree_string += str(tree[i][j]) + ","
			tree_string[tree_string.length()-1] = " "
			tree_string += "|"
		tree_string[tree_string.length()-1] = " "

		# Putting together tree, sequence of kicks and the rest of data
		strData =  tree_string + "\nsequExecutada: " + kickSeq.left(numKicks) +"\n"+ strData

		# Creating file and write data
		var playerName = globalConfig.get_playerName()
		var restrictFileName = globalScript.changeFileName(playerName)
		fileName += "Plays_JG_" +  globalConfig.get_id(fase)+ "_"+restrictFileName+"_"+strDateTime+"_"+randomFlagStr
		var file = File.new()
		var dir = Directory.new()
		if ! dir.dir_exists ("user://toSend/"): dir.make_dir("user://toSend/")
		var inteiro = file.open("user://toSend/"+fileName+".csv",File.WRITE)
		file.store_string(strData)
		file.close()
		savedGame= true
	
	