extends Node

var Connection = preload("res://scripts/Protocol/Connection.gd").Connection
var terrain_scene = preload("res://scenes/Game/Terrain.tscn")
var player_scene = preload("res://scenes/Game/Player.tscn")
var enemy_scene = preload("res://scenes/Game/Enemy.tscn")
var terrain_instance = terrain_scene.instantiate()
var player_instance_1 = player_scene.instantiate()
var player_instance_2 = enemy_scene.instantiate()
var playerNodeID

var username: String
var password: String

var player_uuid: String

var threadGame: Thread

signal receive_uuid

func _ready():
	$LoginOverlay.hide()
	$RegisterOverlay.hide()
	$ChoiceOverlay.show()
	await receive_uuid
	var connection = Connection.new("127.0.0.1", 65432, self.player_uuid) 
	connection.start_connect()
	await connection.connection_achieved
	game()

func set_uid():
	var headers = ['Content-Type: application/json']
	
	var data = {
		"username": "TaGrandBisBisBis",
		"password": "TestPass"
	}
	var body = JSON.stringify(data)
	$HTTPRequest.request("http://0.0.0.0:5000/users/auth", headers, HTTPClient.METHOD_POST, body)

func game():
	spawn_terrain()
	spawn_players()
	_game()

func _game():
	player_instance_1.connect("get_position_and_look", _on_tank_moved)
	player_instance_1.connect("get_canon_orientation", _on_canon_rotate)
	player_instance_1.connect("bullet_shooted", _on_bullet_shooted)
	pass

func _process(delta):
	pass

func spawn_terrain():
	add_child(terrain_instance)

func spawn_players():
	player_instance_1.position = Vector2(100, 100)  
	player_instance_2.position = Vector2(200, 200) 

	add_child(player_instance_1)
	playerNodeID = player_instance_1.get_index()
	add_child(player_instance_2)

func _on_tank_moved(ppal):
	var pos = ppal.pos
	var packet_content = [0x00]
	for b in var_to_bytes(pos):
		packet_content.append(b)
	#print(packet_content)
	#connection.send(packet_content)

func _on_canon_rotate(rot):
	var packet_content = [0x01]
	for b in var_to_bytes(rot):
		packet_content.append(b)
	#print(packet_content)
	#connection.send(packet_content.duplicate())


func _on_bullet_shooted(bul):
	print("Bullet shooted")
	bul.connect("_on_bullet_collide", _bullet_collide)
	bul.connect("_on_bullet_moved", _bullet_moved)

func _bullet_moved(pos):
	print("Bullet pos :" , pos)
	
func _bullet_collide():
	print("Bullet collide !")

func _on_login_overlay_confirmed():
	set_uid()

func _on_http_request_request_completed(result, response_code, headers, body):
	player_uuid = JSON.parse_string(body.get_string_from_utf8()).uuid
	print("UUID : ", player_uuid)
	emit_signal("receive_uuid")


func _on_open_login_overlay_pressed():
	$LoginOverlay.show()
	$ChoiceOverlay.hide()


func _on_open_register_overlay_pressed():
	$RegisterOverlay.show()
	$ChoiceOverlay.hide()


func _on_register_overlay_confirmed():
	var headers = ['Content-Type: application/json']
	
	var data = {
		"username": "TaGrandBisBisBis",
		"password": "TestPass"
	}
	var body = JSON.stringify(data)
	$RegisterRequest.request("http://0.0.0.0:5000/users", headers, HTTPClient.METHOD_POST, body)

func _on_register_request_request_completed(result, response_code, headers, body):
	$RegisterOverlay.hide()
	$LoginOverlay.show()


func _on_register_overlay_canceled():
	$RegisterOverlay.hide()
	$ChoiceOverlay.show()


func _on_login_overlay_canceled():
	$LoginOverlay.hide()
	$ChoiceOverlay.show()
