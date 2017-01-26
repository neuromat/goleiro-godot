extends SceneTree

# Árvore de exemplo
var tree = {
	"00":[0,1,0],
	"10":[0,0,1],
	"20":[1,0,0],
	"1":[.7,0,.3],
	"02":[0,0,1],
	"12":[1,0,0],
	"22":[0,1,0]
}

# Árvore "canalha"
# var tree = {
# 	"0":   [.6,.4],
# 	"11":  [.8,.2],
# 	"001": [.5,.5],
# 	"101": [.2,.8]
#}

# Classe principal que define uma árvore
class Tree:
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
v

# Programa principal, cria a árvore e gera uma string
func _init():
	randomize()
	var st = Tree.new(tree)
	st.disparo()
	for i in range(1,100):
		printraw(st.prox())
	print()
	print(tree.to_json())
	quit()
