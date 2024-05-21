extends CharacterBody2D

@export var speed = 10
@export var rotation_speed = 1.5

signal get_position
signal get_canon_orientation
signal bullet_shooted

var last_position
var rotation_dir = 0

func _ready():
	last_position = position
	$Canon.connect("on_canon_rotate", handle_canon_rotation)
	$Canon.connect("bullet_shooted", handle_bullet_shooted)

func get_input():
	rotation_dir = 0
	velocity = Vector2()
	if Input.is_action_pressed('right'):
		rotation_dir += 1
	if Input.is_action_pressed('left'):
		rotation_dir -= 1
	if Input.is_action_pressed('down'):
		velocity = Vector2(-speed, 0).rotated(rotation)
	if Input.is_action_pressed('up'):
		velocity = Vector2(speed, 0).rotated(rotation)
		

func _physics_process(delta):
	get_position.emit(position)
	'''if position != last_position:
		
		last_position = position'''
	get_input()
	rotation += rotation_dir * rotation_speed * delta
	position += velocity * delta * speed

func handle_canon_rotation(rot):
	get_canon_orientation.emit(rot)
	
func handle_bullet_shooted(bul):
	bullet_shooted.emit(bul)
