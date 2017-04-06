extends Node

const port = 54322
var ipServer = "200.144.254.136"
var connection # your connection (StreamPeerTCP) object
var connected = false
var timeout = 5
var wait = false
var currentFileName = ""


func _ready():
	connection = StreamPeerTCP.new()
	set_process(true) # start processing if connected
	if checkFilesToSend(): currentFileName = takeFile()

func checkFilesToSend():
	var dir = Directory.new()
	if !dir.dir_exists("user://toSend/") :
		#print("1")
		return false
	if dir.open("user://toSend/") != OK:
		#print("2")
		return false
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while (file_name != ""):
		if !dir.current_is_dir():
			return true
		file_name = dir.get_next()
	return false

func takeFile():
	var dir = Directory.new()
	if dir.open("user://toSend/") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if !dir.current_is_dir():
				return file_name
			file_name = dir.get_next()
		return ""

func disconnect():
	if connection.is_connected():
		connection.disconnect()
	set_process(false)

func connect():
	connection = StreamPeerTCP.new()
	connection.connect( ipServer, port )
	if connection.get_status() == connection.STATUS_CONNECTED:
		print( "Connected to "+ipServer+":"+str(port) )
		set_process(true) # start processing if connected
		if checkFilesToSend(): currentFileName = takeFile()

	elif connection.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		print( "Trying to connect "+ipServer+" :"+str(port) )
		print( "Timeout in: ",timeout," seconds")
#		get_node("Timeout").show()
#		set_process(true) # or if trying to connect

	elif connection.get_status() == connection.STATUS_NONE or connection.get_status() == StreamPeerTCP.STATUS_ERROR:
		print( "Couldn't connect to "+ipServer+" :"+str(port) )

	
func _process(delta):
	var data
	var checkSend = 0
	
	if !connection.is_connected( ): connect()
	
	if  checkFilesToSend():
		#Open and read file content
		var file = File.new()
		if file.file_exists("user://toSend/"+currentFileName):
			file.open("user://toSend/"+currentFileName, file.READ)
			var content = file.get_as_text()
			file.close()

			#Sending file data
			if connection.is_connected( ) && connection.get_available_bytes() == 0 && !wait:
				checkSend += connection.get_status()
				data = "Name: "+currentFileName+"\n"+content+"END_FILE\n"
				connection.put_utf8_string(data)

				checkSend += connection.get_status()
				if checkSend == connection.STATUS_CONNECTED*2:
					print("Enviado... file content + END_FILE...")
					wait = true

			#Receiving confirm
			if connection.is_connected( ) && connection.get_available_bytes() > 0 && wait:
				data = connection.get_utf8_string(connection.get_available_bytes())
				print(data)
				if data.casecmp_to("OK_FILE") == 0:
					print("Retornou OK_FILE...")
					wait = false
					var dir = Directory.new()
					if dir.remove("user://toSend/"+currentFileName) != OK: print("Erro ao deletar arquivo" + "user://toSend/"+currentFileName)
					elif checkFilesToSend(): currentFileName = takeFile()
		else:
			# Arquivo não foi aberto... Testar novamente se não tem arquivo
			# para abrir. Se tem, então atualiza o nome do currentFileName
			if checkFilesToSend(): currentFileName = takeFile()
	else: 
			if connection.is_connected( ) && !wait:
				checkSend += connection.get_status()
				data = "END_STREAM\n"
				connection.put_utf8_string(data)
				checkSend += connection.get_status()
				if checkSend == connection.STATUS_CONNECTED*2:
					print("Enviado... END_STREAM")
					wait = true

			if connection.is_connected( ) && connection.get_available_bytes() > 0 && wait:
				data = connection.get_utf8_string(connection.get_available_bytes())
				print(data)
				if data.casecmp_to("OK_STREAM") == 0:
					print("Retornou OK_STREAM...")
					wait = false
					disconnect()