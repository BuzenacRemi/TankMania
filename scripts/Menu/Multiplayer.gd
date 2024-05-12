extends Control

@onready var cam = $Camera2D

func _on_Connect_pressed():
	get_tree().change_scene_to_file("res://scenes/Game/Game.tscn")


func _on_try_connection_pressed():
	pass



