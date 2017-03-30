extends Label

# member variables here, example:
# var a=2
# var b="textvar"
var texto = ""
var txt = ''
var idx = 0

func _ready():
	idx = 0
	txt = ''

func avanca():
	if idx > 6:
		return
	txt = texto.left(idx)
	set_text(txt)
	idx += 1
	


func _on_AnimationPlayer_animation_started( name ):
	texto = name
	idx = 0
	txt = ''
