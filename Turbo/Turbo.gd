extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Players"):
		
		body.get_node("TurboBar").AddTurbo(body,position)
		if body.is_in_group("Bots"):
			body.touchTurbo=true
		#Llaman a la función SpawnTurbo del TurboSpawner (El padre) dandole la posición de este turbo como argumento
		get_parent().SpawnTurbo(position)
		# Se elimina este turbo
		queue_free()
