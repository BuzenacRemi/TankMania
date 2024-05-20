extends Node

const Packet = preload("res://scripts/Protocol/Packet.gd").new().Packet
const Handshake = preload("res://scripts/Protocol/Handshake.gd").new().Handshake

class Connection :
	enum State {HANDSHAKE = 0, CONFIG = 1, QUEUE = 2, PLAY = 3}
	var state : State

	var stream_peer_tcp : StreamPeerTCP = StreamPeerTCP.new()
	var threadWrite: Thread
	var threadRead: Thread
	
	var uuid: String
	
	signal connection_achieved
	
	func _init(addr, port, player_uuid):
		print("Connecting to %s:%d" % [addr, port])
		if stream_peer_tcp.connect_to_host(addr, port) != OK:
			print("Error connecting to host.")
		stream_peer_tcp.poll()
		uuid = player_uuid

	func is_Connected():
		stream_peer_tcp.poll()
		return stream_peer_tcp.get_status() == stream_peer_tcp.STATUS_CONNECTED 
		
	func start_connect():
		threadRead = Thread.new()
		threadRead.start(_handle_packets)
		state = State.HANDSHAKE
		send_handshake_packet()
		
	func _handle_packets():
		while true :
			if is_Connected():
				if stream_peer_tcp.get_available_bytes() > 0:
					var data = stream_peer_tcp.get_data(stream_peer_tcp.get_available_bytes())
					if data[0] == OK:
						var packet = Packet.new().from_tcp_packet(data)
						match state :
							State.HANDSHAKE:
								handshake_handler()
								if state == State.CONFIG :
									send_config_packet()
							State.CONFIG:
								match get_packet_id(data[1]):
									0:
										config_handle(data[1])
									153:
										keep_alive_handle()
							State.QUEUE:
								match get_packet_id(data[1]):
									0:
										queue_handle(data[1])
									153:
										keep_alive_handle()
							State.PLAY:
								print("Play : Données reçues : ", data[1])
						print("Données reçues : ", data[1])
			"""else:
				print("Déconnecté du serveur")"""
	
	func send(data: PackedByteArray) -> bool:
		stream_peer_tcp.poll()
		if !is_Connected():
			print("Error: Stream is not currently connected.")
			return false
		var error: int = stream_peer_tcp.put_data(data)
		if error != OK:
			print("Error writing to stream: ", error)
			return false
		return true
				
	#Handshake part
	func send_handshake_packet():
		stream_peer_tcp.poll()
		var packet_id = PackedByteArray([0x00])
		stream_peer_tcp.put_data(packet_id)
		print("Paquet de handshake envoyé")	

	func handshake_handler():
		print("Successfully handshaked")
		state = State.CONFIG
		
	#---End of Handshake part---
	#Config Part
	var uuid_bytes
	func send_config_packet():
		uuid_bytes = uuid.to_utf8_buffer()
		stream_peer_tcp.poll()
		var packet_content = PackedByteArray([0x00])
		for byte in uuid_bytes:
			packet_content.append(byte)
		stream_peer_tcp.put_data(packet_content)
		print("Paquet de config envoyé")

	func config_handle(packet_data : PackedByteArray):
		var data = get_packet_data(packet_data)
		if uuid_bytes == data:
			state = State.QUEUE
			print("Successfully configured entering in queue")
		else :
			print("Bad data :", data)
	#---End of config part---
	#Queue Part
	func queue_handle(packet_data: PackedByteArray):
		var data = get_packet_data(packet_data)
		if data == PackedByteArray([45, 49]):
			print("Queue finished")
			connection_achieved.emit()
		else :
			print("Pos in queue : ", data)
			send_queue_packet()
	
	func send_queue_packet():
		stream_peer_tcp.poll()
		var packet_id = PackedByteArray([0x00])
		stream_peer_tcp.put_data(packet_id)
		print("Paquet de queue envoyé")
	#---End of queue part---
	#Keep Alive Part
	func keep_alive_handle():
		stream_peer_tcp.poll()
		var packet_id = PackedByteArray([0x99])
		stream_peer_tcp.put_data(packet_id)
		print("Paquet de keep alive envoyé")	
	#---End of keep alive part---
	#---Play Part---
	
	#---End of play part---
	func get_packet_data(data : PackedByteArray):
		var is_first = true
		var content_arr = PackedByteArray()
		for byte in data :
			if is_first :	
				is_first = false
			else :
				content_arr.append(byte)
		return content_arr
	
	func get_packet_id(data : PackedByteArray):
		return data[0]
