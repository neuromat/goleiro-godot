extends Node

var texture_right_left =  ImageTexture.new()
var texture_wrong_left = ImageTexture.new()
var texture_right_right = ImageTexture.new()
var texture_wrong_right = ImageTexture.new()
var texture_right_center = ImageTexture.new()
var texture_wrong_center = ImageTexture.new()
var imageName = {"0":"left", "1":"center", "2":"right"}

func updateHistoric(defenseSeq, kickSeq):
	var local_kickSeq = kickSeq + "XXXXXXXXXX"
	var local_defenseSeq = defenseSeq  + "XXXXXXXXXX"
	var pos
	if kickSeq.length() > 8 && defenseSeq.length() > 8: pos = defenseSeq.length() - 8
	else : pos = 0
	for i in range(pos,pos+8):
		if local_defenseSeq[i] == "X" || local_kickSeq[i] == "X": break
		if local_defenseSeq[i] == local_kickSeq[i]: 
			get_node("win0"+str(i-pos+1)).set_texture(get("texture_right_"+imageName[local_kickSeq[i]]))
		else:
			get_node("win0"+str(i-pos+1)).set_texture(get("texture_wrong_"+imageName[local_kickSeq[i]]))

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	texture_right_left.load("res://scenes/historicPlays/images/rightLeft.png")
	texture_wrong_left.load("res://scenes/historicPlays/images/wrongLeft.png")
	texture_right_right.load("res://scenes/historicPlays/images/rightRight.png")
	texture_wrong_right.load("res://scenes/historicPlays/images/wrongRight.png")
	texture_right_center.load("res://scenes/historicPlays/images/rightCenter.png")
	texture_wrong_center.load("res://scenes/historicPlays/images/wrongCenter.png")