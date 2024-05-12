extends Control

func _ready():
	pass 

func _on_SingleButton_pressed():
	pass

func _on_MultiButton_pressed():
	get_tree().change_scene_to_file("res://scenes/Menu/Multiplayer.tscn") 
