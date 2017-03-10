extends Node

const PLAYER_CONNECT = 0
const PLAYER_DISCONNECT = 1
const PLAYER_DATA = 2
const NAME_TAKEN = 3
const MESSAGE = 4

const port = 3560
var ipServer = "127.0.0.1"
var connection # your connection (StreamPeerTCP) object
var peer # your data transfer (PacketPeerStream) object
var connected = false
var clones = {} # dictionary for finding clones more easily
var sleep = 0 
var notSended = 0
var timeout = 5
var wait = false
var currentFileName

func _ready():
	connection = StreamPeerTCP.new()
	connection.connect( ipServer, port )
	peer = PacketPeerStream.new()
	peer.set_stream_peer(connection)
	if connection.get_status() == connection.STATUS_CONNECTED:
		print( "Connected to "+ipServer+":"+str(port) )
		set_process(true) # start processing if connected
		connected = true

	elif connection.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		print( "Trying to connect "+ipServer+" :"+str(port) )
		print( "Timeout in: ",timeout," seconds")
#		get_node("Timeout").show()
#		set_process(true) # or if trying to connect
	elif connection.get_status() == connection.STATUS_NONE or connection.get_status() == StreamPeerTCP.STATUS_ERROR:
		print( "Couldn't connect to "+ipServer+" :"+str(port) )
		
	if checkFilesToSend(): currentFileName = takeFile()

func checkFilesToSend():
	var dir = Directory.new()
	if !dir.dir_exists("user://toSend/") :
		print("1")
		return false
	if dir.open("user://toSend/") != OK:
		print("2")
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
		return ""

func _process(delta):
	var data
	var checkSend = 0
	
	if  checkFilesToSend():
		#Open and read file content
		var file = File.new()
		if file.file_exists("user://toSend/"+currentFileName):
			file.open("user://toSend/"+currentFileName, file.READ)
			var content = file.get_as_text()
			file.close()

			#Sending data
			if connection.is_connected( ) && connection.get_available_bytes() == 0 && !wait:
				checkSend += connection.get_status()
				data = "Name: "+currentFileName+"\n"+content+"END"
				connection.put_utf8_string(data)

				checkSend += connection.get_status()
				if checkSend == connection.STATUS_CONNECTED*2:
					print("Enviado...")
					wait = true

			#Receiving confirm
			if connection.is_connected( ) && connection.get_available_bytes() > 0 && wait:
				data = connection.get_utf8_string(connection.get_available_bytes())
				print(data)
				if data.casecmp_to("OK") == 0:
					print("Retornou ok...")
				wait = false

		else: print("Arquivo não encontrado")