extends Node

var current_scene = null

func goToScene(scene):
	current_scene.queue_free()
	current_scene = load(scene).instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
	set_process(true)

func quit():
	get_tree().quit()
	
func _process(delta):
	if Input.is_action_pressed("ui_quit"): quit()

func genSeq(size, tree):
	randomize()
	var st = Tree.new(tree)
	st.disparo()
	for i in range(1,size-1):
		st.prox()
		#print(st.prox())
	#print(st.estado)
	#print(tree.to_json())
	return st.estado

class Tree:
	#Classe Tree é a classe que recebe a árvore de contexto e gera as sequências
	
	var trans ={}						  # Tabela de transições
	var tam								  # Tamanho da tabela
	var estado=""						  # Histórico das escolhas

	func _init(desc):
		trans = desc
		tam = desc.size()
		#  internamente armazenamos a acumulada
		for v in desc.values():
			for i in 	range(1,v.size()):
				v[i] += v[i-1]

	# Seleciona o próximo valor para o sufixo idx
	func sel(idx):
		var p = randf()
		var pps = trans[idx]
		for i in range(0,pps.size()-1):
			if p < pps[i]:
				return str(i)
		return str(pps.size()-1)


	##################################################################
	# As duas funções abaixo poderiam ser agrupadas em um único
	# gerador/iterador, mas aparentemente o GDScript possui limitações
	# quanto a isso

	# Inicializa a árvore
	func disparo():
		var ix = int(rand_range(0,tam))
		estado = trans.keys()[ix]

	# Devolve o próximo valor em função do estado corrente
	func prox():
		#procura um sufixo a partir da direita
		var pos = estado.length()-1
		var sufix = estado.right(pos)
		
		while !trans.has(sufix) && pos >= 0:
			pos -= 1

			# teste para o caso onde não existe sufixo registrado
			# marquei o erro com "X", mas o programa poderia para
			# imediatamente
			if pos < 0 :
				estado += "X"
				return "X"

			sufix = estado.right(pos)
		# sufixo encontrado, sorteia o próximo valor
		var x = sel(sufix)
		estado += x
		return x

