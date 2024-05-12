extends Node

var Connection = preload("res://scripts/Protocol/Connection.gd").Connection
var terrain_scene = preload("res://scenes/Game/Terrain.tscn")
var player_scene = preload("res://scenes/Game/Player.tscn")
var enemy_scene = preload("res://scenes/Game/Enemy.tscn")
var terrain_instance = terrain_scene.instantiate()
var player_instance_1 = player_scene.instantiate()
var player_instance_2 = enemy_scene.instantiate()
var playerNodeID

var threadGame: Thread

var connection = Connection.new("127.0.0.1", 65432)

func _init():
	connection.start_connect()
	while !connection.is_Connected():
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
	print(player_instance_1.name)
	add_child(player_instance_2)

func _on_tank_moved(ppal):
	var pos = ppal.pos
	var packet_content = [0x00]
	for b in var_to_bytes(pos):
		packet_content.append(b)
	#print(packet_content)
	connection.send(packet_content)

func _on_canon_rotate(rot):
	var packet_content = [0x01]
	for b in var_to_bytes(rot):
		packet_content.append(b)
	#print(packet_content)
	connection.send(packet_content.duplicate())


func _on_bullet_shooted(bul):
	print("Bullet shooted")
	bul.connect("_on_bullet_collide", _bullet_collide)
	bul.connect("_on_bullet_moved", _bullet_moved)

func _bullet_moved(pos):
	print("Bullet pos :" , pos)
	
func _bullet_collide():
	print("Bullet collide !")
	



