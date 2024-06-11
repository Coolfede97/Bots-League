extends CharacterBody2D

@export var speed=200

func _physics_process(delta):
	move_and_slide()
	


func _on_area_2d_body_entered(body):
	if body.get_parent().is_in_group("Walls"):
		if is_on_ceiling() or is_on_floor():
			velocity.y*=-1
			velocity*=0.7
		elif is_on_wall():
			velocity.x*=-1
			velocity*=0.7
		print("hola")
	elif body.is_in_group("Players"):
		velocity=(global_position-body.global_position).normalized()*speed
