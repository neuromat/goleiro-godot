#!/usr/bin/python3

from socketserver import *
import os  
from config import config
from insert import insertDB

def make_game_key(fileName):
	splited = fileName.split(',')
	if len(splited) is not 3 : return ""
	else: 
		splited[0] = splited[0][len(splited[0])-6:len(splited[0])]
		splited[2] = splited[2][0:3]
		return "%s_%s_%s" % (splited[0],splited[1],splited[2])



TCPServer.allow_reuse_address = True

class MyTCPHandler(StreamRequestHandler):
	def handle(self):
		streamData = True
		fileContent = ""
		while(streamData):
			fileManage = True
			while(fileManage):
				self.data = self.rfile.readline()
				data = self.data.decode('utf-8')
				if self.data.startswith(b"END_FILE"):
					fileManage = False
					break

				if self.data.startswith(b"END_STREAM"):
					streamData = False
					break

				if self.data.startswith(b"Name"):
					fileName = data.split()[1]
					print(fileName)
				else: fileContent += data


			if fileManage == False and os.path.isfile("./receivedFiles/"+fileName) == False:
				if os.path.isdir("./receivedFiles/") == False:
					os.mkdir("receivedFiles")
				newFile = open("./receivedFiles/"+fileName, 'w')
				newFile.write(fileContent)
				gameKey = make_game_key(fileName)
				if gameKey is "": print("Nome do arquivo recebido fora do padrão...")
				elif insertDB(gameKey,fileContent) == False: print("Não gravou no banco de dados!")
				else: print("Gravou no banco de dados!")
				fileContent = ""

			if streamData == True and fileManage == False:
				print("Enviando... OK_FILE\n")
				self.wfile.write(b"OK_FILE")

		if streamData == False:
			print("Enviando... OK_STREAM\n")
			self.wfile.write(b"OK_STREAM")
server = TCPServer(("127.0.0.1", 3560), MyTCPHandler)
server.serve_forever()

