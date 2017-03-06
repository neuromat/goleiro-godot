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

var timeout = 5

func _ready():
	connection = StreamPeerTCP.new()
	connection.connect( ipServer, port )
	peer = PacketPeerStream.new()
	peer.set_stream_peer( connection )
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

func _process( delta ):
	if connected:
		connection.put_utf8_string("test...\n")