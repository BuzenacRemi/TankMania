class Packet :
	var Packet_Id : int 
	var Content : PackedByteArray
	
	func from_tcp_packet(data):
		var is_first = true
		var content_arr = []
		for byte in data[1] :
			if is_first :	
				self.Packet_Id = byte
				is_first = false
			else :
				content_arr.append(byte)
		self.Content = content_arr


	func get_packet_id() -> int:
		return self.Packet_Id

	func get_packet_content() -> PackedByteArray:
		return self.Content
