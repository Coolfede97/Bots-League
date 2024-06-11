extends Node2D

@export var turboInstance: PackedScene

#Spawnea un turbo en el vector del argumento
func SpawnTurbo(vector):
	#Se esperan 5 seg.
	await get_tree().create_timer(5).timeout
	var turbo=turboInstance.instantiate()
	turbo.position=vector
	self.add_child(turbo)
	
