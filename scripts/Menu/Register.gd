extends Node


func _on_button_pressed():
	var api_url = "http://172.22.0.2:5000/users"
	var body = '{
	"password": "hyujbezn,pm,bgvnj,jn,d,sz,koc",
	"username": "TaGrandBisBis","
	}'
	print("Send request to :", api_url)
	var status = $HTTPRequest.request(api_url,)
	print("Status :", status)
