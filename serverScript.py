#!/usr/bin/python3

from socketserver import *

TCPServer.allow_reuse_address = True

class MyTCPHandler(StreamRequestHandler):
	def handle(self):
		fileContent = ""
		while(True):
			self.data = self.rfile.readline()
			data = self.data.decode('utf-8')
			if self.data.startswith(b"END"):
				print("Fala safada")
				break
			if self.data.startswith(b"Name"):
				fileName = data.split()[1]
				print(fileName)
			else: fileContent += data

		print("Arquivo:\n"+fileContent)
		print("Enviando...\n")
		self.wfile.write(b"OK")

server = TCPServer(("127.0.0.1", 3560), MyTCPHandler)
server.serve_forever()

