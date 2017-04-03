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
const animGoalKepper = "goalKeeper/Goleiro/Animação-Goleiro"
const animKicker = "Kicker/Cobrador/AnimationPlayer"
const animBall = "ball/Bola/Sprite/AnimationPlayer"

func _button_nextLvl_pressed():
	globalScript.goToScene("res://scenes/jogo_goleiro/nivel02.tscn")

func _button_fimJogo_pressed(callMode):
	get_node("janelaFim").show()
	get_node("b_endGame").hide()
	get_node("janelaFim/scoreBoard").set_text("Jogo do Gooleiro fase 1\n"+str(numDefenses)+"/"+str(numKicks))
	saveData(callMode)

func _resultKick():
	numKicks += 1
	historicPlays += kickSeq[numKicks-1] + ",?," +defenseSeq[numKicks-1]+ ","
	if defenseSeq[numKicks-1] == kickSeq[numKicks-1]: 
		numDefenses += 1
		historicPlays += "True,"
	else:
		numGols += 1
		historicPlays += "False,"
	historicPlays += str(globalTime - lastRecordedTime) + "\n"
	lastRecordedTime = globalTime

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
	if get_node(animGoalKepper).is_playing() && get_node(animKicker).get_current_animation_pos() >= 0.75:
		if defenseSeq[numKicks-1] == kickSeq[numKicks-1]: get_node("phrase/AnimationPlayer").play("defendeu")
		else: get_node("phrase/AnimationPlayer").play("perdeu")
		
	if !get_node(animGoalKepper).is_playing() && !get_node(animKicker).is_playing() && !get_node(animBall).is_playing() && !get_node("phrase/AnimationPlayer").is_playing(): return false
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
	get_node("janelaFim/b_nextLvl").connect("pressed",self,"_button_nextLvl_pressed")
	get_node("janelaFim/b_sairGame").connect("pressed",self,"_quit")
	get_node("b_chutes/b_baixo").connect("pressed",self,"_button_kick_pressed",["1"])
	get_node("b_chutes/b_esquerda").connect("pressed",self,"_button_kick_pressed",["0"])
	get_node("b_chutes/b_direita").connect("pressed",self,"_button_kick_pressed",["2"])
	get_node("janelaFim").hide()
	get_node("janelaFim/nome").set_text(globalConfig.get_playerName().to_upper())
	get_node(animGoalKepper).set_speed(animSpeed)
	get_node(animKicker).set_speed(animSpeed)
	get_node(animBall).set_speed(animSpeed)
	#OS.set_window_fullscreen(true)
	
func _process(delta):
	globalTime += delta
	timeControlAnim += delta

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
		randomize()
		var randomFlag = str(round(rand_range(0,999)))
		var strData = "experimentGroup,game,playID,phase,gameTime,relaxTime,playerMachine,YYMMDD,HHMMSS,random,playerAlias,playLimit,totalCorrect,successRate,gameMode,status,move,waitedResult,ehRandom,optionChosen,correct,movementTime\n"
		var strCommonData = ""
		strDateTime = str(dateTime.year)+str(dateTime.month)+str(dateTime.day)+","
		strDateTime += str(dateTime.hour)+str(dateTime.minute)+str(dateTime.second)+","+randomFlag
		
		
		strCommonData += globalConfig.get_packName() + ",JG,"+ globalConfig.get_id(0)+",ph1,"+str(globalTime)+",0,XX-XX,"+strDateTime+","
		strCommonData += globalConfig.get_playerName()+","+ str(numKicks)+","+str(numDefenses)
		if numKicks == 0 : strCommonData += ",0.0,"
		else: strCommonData += ","+str(numDefenses/numKicks)+","
		strCommonData +=globalConfig.get_seqMode(0)+","+str(callMode)+","
		
		var historicPlaysArray = historicPlays.split("\n")
		for line in range(0,historicPlaysArray.size()-1):
			strData += strCommonData + str(line+1) +","+ historicPlaysArray[line]+"\n"

		# Creating file and write data
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
	
	