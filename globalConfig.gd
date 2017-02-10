extends Node

var level = []      # Dados de configuração, ordenado por fase, em formato dicionario
var error = [false,0] # Some error happened, so we need stop program. Second coordinate represents the erro number
var PlayerName = ""

func checkConfigFile():
	pass

func set_playerName(name):
	PlayerName = name
	
func get_level():
	return level
	
func get_seqMode(fase):
	if level[fase]["readSequ"] == "true" : return "readSequence"
	else: return "readTree"
	
func get_tree(fase):
	var treeFile = level[fase]
	var tree ={}
	if !treeFile.has("tree") :
		return null
	for i in range(0,treeFile["tree"].size()):
		for j in treeFile["tree"][i].keys():
			tree[j] = treeFile["tree"][i][j]
	return tree

func get_qntChutes(fase):
	return int(level[fase]["limitPlays"])

func get_id(fase):
	return level[fase]["id"]
	
func get_playerName():
	return PlayerName
	
func loadPacketNames():
	var dir = Directory.new()
	var dicPackets = {}
	# abrir o diretorio user:// onde estao os pacotes
	if  dir.open( "user://packets" ) == OK:
		# e encontrar todos os pacotes disponiveis no diretorio
		dir.list_dir_begin()
		var fileName = dir.get_next()
		while (fileName != ""):
			if (fileName == "." || fileName == ".."):
				fileName = dir.get_next()
				continue
			if dir.current_is_dir():
				# encontrado um diretorio de pacotes
				dicPackets[fileName] = dir.get_current_dir() + "/" + fileName
				fileName = dir.get_next()
			else:
				# se nao existe o diretorio, gravar no log
				print("Erro: não   existe o diretório packets em ", OS.get_data_dir())
		if dicPackets.size() == 0:
			print("Erro: não existem pacotes no diret������ório ", OS.get_data_dir())
	return dicPackets


func loadPacketConfFiles(packetPath):
	var dir = Directory.new()
	var file = File.new()
	var fileName
	var path            # caminho completo, nao apenas fileName, para o open
	var text            # conteudo do arquivo jason
	var dict = {}       # apenas um nivel, nao encontrei sintaxe para  var dict = [ {} ]
	var fases = []      # ordem dos levels, dado que a leitura no diretorio nao garante ordem
	var tmpLevel = []   # recebe as fases na ordem de leitura, em formato dicionario
	level = []      # Clean level array
		
	# abrir o diretorio de pacotes selecionado
	if  dir.open(packetPath) == OK:
		# e percorrer a lista de arquivos (nao diretorios)
		dir.list_dir_begin()
		fileName = dir.get_next()

		while (fileName != ""):
			# Guarda o path completo próximo arquivo/diretório. Será usado no file.open
			path = packetPath + "/" + fileName
			# ignorar diretorios
			if !dir.current_is_dir():
				file.open(path, file.READ)
				text = file.get_as_text()
				# when you do something like content.append(info), you aren't making a copy of the data, 
				# you are simply appending a reference to the data. 
				var dict = {}   
				
				# pode haver outros arquivos no diretorio, mas soh interessam os de formato json
				if dict.parse_json(text) == OK:
					fases.append(int(dict["level"]));
					tmpLevel.append(dict)
				file.close()
			fileName = dir.get_next()

	# os levels indicados nos arquivos de configuracao devem ser sequenciais
	# nao obrigatoriamente iniciando em zero
	var tmpFases = [] + fases
	tmpFases.sort();
	
	# deve haver pelo menor 1 arquivo de configuracao para fazer uma fase
	if tmpFases.size() < 1:
		print("Erro: número de arquivos de configuração inválido (", tmpFases.size(),") em ", OS.get_data_dir())
		return !OK

	var foraDeOrdem = false
	for i in range(0,tmpFases.size()-1):
		if tmpFases[i] != tmpFases[i]: 
			foraDeOrdem = true
	if  foraDeOrdem:
		# ha falha na sequencia
		print("Erro: o parâmetro level nos arquivos não segue a sequência esperada de 0 a N: ", tmpFases)
		return !OK
	else:
		# ordenar levels pela sequencia de fases: level[0] fase 1, level[1] fase 2, ...
		# tmpfases está ordenado, fases está na ordem de leitura
		var j
		for i in range(tmpFases[0], tmpFases[tmpFases.size()-1]+1):
			j = 0
			while fases[j] != i: 
				j = j + 1
			level.append(tmpLevel[j])
			
		
	return OK