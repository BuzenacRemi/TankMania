class Handshake :
	var handshake_data: int = 10
	var packet_id: PackedByteArray = PackedByteArray([0x00])
	
	func handle_Handshake_Packet(packet):
		if packet.get_packet_id() == 0x00 :
			if packet.get_packet_content() == handshake_data+1 :
				print("Handshake Successful")
		else :
			print("Bad handshake")
