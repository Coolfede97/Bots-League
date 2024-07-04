extends RigidBody2D

@export var walkSpeed=int()
@export var turboSpeed=int()
@export var hyperTurboSpeed=float()
@export var turboRemaining=float()
var direction=Vector2()
var velocity=Vector2()
var hyp=float()
var BTBV #Bot to Ball Vector
@export var MDTT=int() #La distancia máxima entre el bot y la pelota para usar el Turbo-- Max Distance To Turbo
@export var mDTT=int() #La distancia minima entre el bot y la pelota para usar el Turbo-- Min Distance To Turbo
@export var MDTHT=int() #La distancia máxima entre el bot y la pelota para usar el HyperTurbo-- Max Distance To HyperTurbo
var touchTurbo=bool()
@export var ball : RigidBody2D
var move=true
#Obtiene la magnitud de un vector dado
func GetMagnitude(vector):
	var distance=sqrt(vector.x**2+vector.y**2)
	return distance

func hypotenuseNormalized(vector):
	hyp=sqrt(vector.x**2+vector.y**2)
	var vectorNormalized=vector/hyp
	return vectorNormalized

func _physics_process(delta):
	#Vector que va desde el bot hasta la pelota
	if move==true:
		if ball!=null:
			BTBV=ball.global_position-global_position
			
			#Obtiene el vector normalizado de BTBV
			direction=hypotenuseNormalized(BTBV)
			
			#Si la distancia entre el bot es menor que MDTT y mayor que mDTT y queda turbo, se usa
			if GetMagnitude(BTBV)<MDTT and GetMagnitude(BTBV)>mDTT and turboRemaining>0:
				#Igual que en el script PlayerBody, Buscar: I:1
				velocity=direction*turboSpeed
				get_node("TurboBar").ChangeValue(turboRemaining)
				turboRemaining-=get_process_delta_time()/4.5
			
			#Si la distancia entre el bot es menor que MDTHT y queda turbo, se usa
			elif GetMagnitude(BTBV)<MDTHT and turboRemaining>0:
				#Igual que en el script PlayerBody, Buscar: I:1
				velocity=direction*hyperTurboSpeed
				get_node("TurboBar").ChangeValue(turboRemaining)
				turboRemaining-=get_process_delta_time()/1.5
			else:
				#Igual que en el script PlayerBody, Buscar: I:2
				velocity=direction*walkSpeed
			apply_central_force(velocity)
			
			# Soluciona que el bot atrape la pelota contra la pared
			#Si su velocidad es poca (Porque su velocidad es mínima al encerrar a la pelota)
			if GetMagnitude(linear_velocity)<3.1:
				#Mientras su distancia contra la pelota no sea mayor a 100 px
				while GetMagnitude(BTBV)<100:
					#Se mueve para el lado opuesto con respecto BTBV
					apply_central_force(-velocity)
					#Para que no deje de responder se espera un poco
					await get_tree().create_timer(0.01).timeout
				
			
		
