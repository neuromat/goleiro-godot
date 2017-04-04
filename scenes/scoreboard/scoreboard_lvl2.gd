extends TextureFrame

var score_decimal_left
var score_unit_left
var score_decimal_right
var score_unit_right


var texture_decimal_left =  ImageTexture.new()
var texture_unit_left = ImageTexture.new()
var texture_decimal_right = ImageTexture.new()
var texture_unit_right = ImageTexture.new()

func change(var left, var right):
	score_decimal_left = int (left/10)
	score_unit_left = left % 10
	score_decimal_right = int(right/10)
	score_unit_right = right % 10
	texture_decimal_left.load("res://scenes/scoreboard/images/Impresso-"+str(score_decimal_left)+".png")
	texture_unit_left.load("res://scenes/scoreboard/images/Impresso-"+str(score_unit_left)+".png")
	texture_decimal_right.load("res://scenes/scoreboard/images/Impresso-"+str(score_decimal_right)+".png")
	texture_unit_right.load("res://scenes/scoreboard/images/Impresso-"+str(score_unit_right)+".png")
	get_node("score_decimal_left").set_texture(texture_decimal_left)
	get_node("score_units_left").set_texture(texture_unit_left)
	get_node("score_decimal_right").set_texture(texture_decimal_right)
	get_node("score_units_right").set_texture(texture_unit_right)

func _ready():
	pass
