#!/usr/bin/python3

from socketserver import *
import os  


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

			if streamData == True and fileManage == False:
				print("Enviando... OK_FILE\n")
				self.wfile.write(b"OK_FILE")
		if streamData == False:
			print("Enviando... OK_STREAM\n")
			self.wfile.write(b"OK_STREAM")
server = TCPServer(("127.0.0.1", 3560), MyTCPHandler)
server.serve_forever()

