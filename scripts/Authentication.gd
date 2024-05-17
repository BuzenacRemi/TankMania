extends Node

class Authentication:
	var username: String
	var password: String
	var http_request: HTTPRequest = HTTPRequest.new()

	func is_correct_creds():
		print(http_request.request_raw("http://172.22.0.3:5000/users", PackedStringArray(), HTTPClient.METHOD_GET, var_to_bytes('{
		"password": "hyujbezn,pm,bgvnj,jn,d,sz,koc",
		"username": "TaGrandBisBis"
		}')))
		
