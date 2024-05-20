extends CharacterBody2D

var bullet_scene = preload("res://scenes/Game/Bullet.tscn")
var aim = null
var fire_point = null

var prev_rotation

signal on_canon_rotate
signal bullet_shooted
	
func _ready():
	prev_rotation = rotation
	aim = get_node("Aim")
	fire_point = get_node("FirePoint")
	aim.hide()

func _physics_process(delta):
	look_at(get_global_mouse_position())
	if prev_rotation != rotation:
		on_canon_rotate.emit(rotation)

func _process(delta):
	if Input.is_action_just_pressed("shoot"): 
		shoot()
	if Input.is_action_just_pressed("aim"):
		show_aim()
	if Input.is_action_just_released("aim"):
		hide_aim()
		

func shoot():
	var bullet_instance = bullet_scene.instantiate()
	bullet_instance.position = fire_point.global_position
	var direction = (get_global_mouse_position() - fire_point.global_position).normalized()
	bullet_instance.initialize(direction.angle())
	owner.get_parent().add_child(bullet_instance)
	bullet_shooted.emit(bullet_instance)
	
func show_aim():
	aim.show()
	
func hide_aim():
	aim.hide()

