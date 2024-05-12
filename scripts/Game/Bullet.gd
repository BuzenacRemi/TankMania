extends CharacterBody2D

@export var speed = 400 
@export var bouce_count = 0

signal _on_bullet_moved
signal _on_bullet_collide

func initialize(angle):
	rotation = angle
	velocity = Vector2(speed, 0).rotated(rotation)

func _ready():
	pass  

func _physics_process(delta):
	_on_bullet_moved.emit(position)
	var collision = move_and_collide(velocity * delta)
	if collision:
		_on_bullet_collide.emit()
		bouce_count += 1
		if bouce_count >= 3:
			queue_free()
		velocity = velocity.bounce(collision.get_normal())
