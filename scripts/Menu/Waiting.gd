extends Control

func _ready():
	pass

func _on_Button_pressed():
	get_tree().change_scene_to_file("res://scenes/Game/Game.tscn")
