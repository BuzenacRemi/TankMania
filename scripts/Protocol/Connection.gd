extends Node

const Packet = preload("res://scripts/Protocol/Packet.gd").new().Packet
const Handshake = preload("res://scripts/Protocol/Handshake.gd").new().Handshake
const Uuid = preload("res://scripts/Protocol/uuid.gd").new().Uuid

class Connection :
	enum State {HANDSHAKE = 0, CONFIG = 1, QUEUE = 2, PLAY = 3}
	var state : State

	var stream_peer_tcp : StreamPeerTCP = StreamPeerTCP.new()
	var threadWrite: Thread
	var threadRead: Thread
	
	var queue_pos: int
	
	func _init(addr, port):
		print("Connecting to %s:%d" % [addr, port])


		if stream_peer_tcp.connect_to_host(addr, port) != OK:
			print("Error connecting to host.")
		while !is_Connected():
			print("Not connected yet... Retrying...")
		print(stream_peer_tcp.get_status())
	
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
			else:
				print("Déconnecté du serveur")
	
	func send(data: PackedByteArray) -> bool:
		stream_peer_tcp.poll()
		if is_Connected():
			print("Error: Stream is not currently connected.")
			return false
		print(data)
		var error: int = stream_peer_tcp.put_data(data)
		if error != OK:
			print("Error writing to stream: ", error)
			return false
		return true

	#Handshake part
	func send_handshake_packet():
		var packet_id = PackedByteArray([0x00])
		stream_peer_tcp.put_data(packet_id)
		print("Paquet de handshake envoyé")	

	func handshake_handler():
		print("Successfully handshaked")
		state = State.CONFIG
		
	#---End of Handshake part---
	#Config Part 
	var player_uuid = Uuid.v4()
	var uuid_bytes = player_uuid.to_utf8_buffer()

	func send_config_packet():
		var packet_content = PackedByteArray([0x00])
		for byte in uuid_bytes :
			print(byte)
			packet_content.append(byte)
		stream_peer_tcp.put_data(packet_content)
		print(packet_content)
		print("Paquet de config envoyé")

	func config_handle(packet_data : PackedByteArray):
		var data = get_packet_data(packet_data)
		if uuid_bytes == data:
			print("Successfully configured entering in queue")
			state = State.QUEUE
		else :
			print("Bad data :", data)
	#---End of config part---
	#Queue Part
	func queue_handle(packet_data: PackedByteArray):
		var data = get_packet_data(packet_data)
		print("Pos in queue : ", data)
	
	func send_queue_packet():
		var packet_id = PackedByteArray([0x00])
		stream_peer_tcp.put_data(packet_id)
		print("Paquet de queue envoyé")	
	#---End of queue part---
	#Keep Alive Part
	func keep_alive_handle():
		var packet_id = PackedByteArray([0x99])
		stream_peer_tcp.put_data(packet_id)
		print("Paquet de keep alive envoyé")	
	#---End of keep alive part---
	
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



