extends RigidBody2D

var functionCallable=true
var functionCallable2=true
@export var isOfensive=bool()
var cronometer: float
# Radius of the bot's collision = 24.69
# Radius of the ball's collision = 17.06
var AOPPSWS=111.06275 # Amount Of Pixels Per Second Walk Speed - En un segundo avanza 111.06275
@export var walkSpeed=int()
@export var turboSpeed=int()
@export var hyperTurboSpeed=float() 
@export var turboRemaining=float()
@export var turboVector=[Vector2(),Vector2()]
var direction=Vector2()
var velocity=Vector2()
var BTBV #Bot to Ball Vector
@export var MDTT=int() #La distancia máxima entre el bot y la pelota para usar el Turbo-- Max Distance To Turbo
@export var mDTT=int() #La distancia minima entre el bot y la pelota para usar el Turbo-- Min Distance To Turbo
@export var MDTHT=int() #La distancia máxima entre el bot y la pelota para usar el HyperTurbo-- Max Distance To HyperTurbo
@export var player: RigidBody2D
@export var ball: RigidBody2D
@onready var calculator = $Calculator
var ballFP=Vector2(0,0) # Ball Future Position
@onready var bot_2_ray_cast = $Bot2RayCast
@onready var bot_2_ray_cast_pts = $Bot2RayCastPTS
@export var upCorner: Node2D
@export var downCorner: Node2D
@export var DTBBS=float() #Distance To Ball Before Shot
@export var timePrediction: Array=[
	0.6, 0.7, 0.8, 0.9, 1.0,
	1.1, 1.2, 1.3, 1.4, 1.5,
	1.6, 1.7, 1.8, 1.9, 2.0]
@export var goalCenterVector=Vector2()
@export var halfPitch=float()
var move=true

#Obtiene la magnitud de un vector dado
func GetMagnitude(vector):
	var distance=sqrt(vector.x**2+vector.y**2)
	return distance
	
#Obtiene el vector normalizado del vector dado
func hypotenuseNormalized(vector):
	var hyp=sqrt(vector.x**2+vector.y**2)
	var vectorNormalized=vector/hyp
	return vectorNormalized

#This obtains the ball future position in case it bounces with a wall
func FuturePositionBounce():
	var collisionPoint=ball.ball_ray_cast.get_collision_point()
	var ballVelocityNormalized=hypotenuseNormalized(ball.linear_velocity)
	# Collision Point To Ball Position Magnitude
	var CPTBPM = GetMagnitude(ball.position-collisionPoint)
	# The remaining part of the raycast after the wall
	var magnitudeRemaining=GetMagnitude(ball.ball_ray_cast.target_position)-CPTBPM
	var wallNormal= ball.ball_ray_cast.get_collision_normal()
	var unitVector = GetOpositeUnitVector(ballVelocityNormalized,wallNormal)
	var localballFP=collisionPoint+unitVector*magnitudeRemaining

	ball.ball_ray_cast.target_position=localballFP-ball.position
	return localballFP

#This gives the balls's X vector after it bounces
func GetOpositeUnitVector(ballVelocityNormalized,wallNormal):
	if wallNormal.x==1:
		ballVelocityNormalized.x*=-1
		return ballVelocityNormalized
	elif wallNormal.x==-1:
		ballVelocityNormalized.x*=-1
		return ballVelocityNormalized
	elif wallNormal.y==1:
		ballVelocityNormalized.y*=-1
		return ballVelocityNormalized
	elif wallNormal.y==-1:
		ballVelocityNormalized.y*=-1
		return ballVelocityNormalized
func resetScript():
	cronometer=0
	functionCallable=true
func _physics_process(delta):
	if linear_velocity==Vector2(0,0) and isOfensive and move==true:
		cronometer+=get_process_delta_time()
		if cronometer>8:
			resetScript()
	elif ball!=null and position.distance_to(ball.position)<115 and move==true:
		cronometer+=get_process_delta_time()
		if cronometer>6:
			cronometer=0
			calculator.destrabando=true
			var direction=hypotenuseNormalized(position-ball.position)
			while GetMagnitude(position-ball.position)<120:
				apply_central_force(direction*walkSpeed*delta)
				await get_tree().create_timer(0.0000001).timeout
			calculator.destrabando=false
			
	else:
		cronometer=0	
	bot_2_ray_cast.global_rotation=0
	bot_2_ray_cast_pts.global_rotation=0
	if functionCallable==true and isOfensive and calculator.lookingForturbo==false and ball!=null:
		hitBall(delta)
		functionCallable=false
	elif functionCallable2==true and !isOfensive and ball!=null:
		defenseGoal(delta)
#	if move==true:
#		if get_parent().get_node("Ball")!=null:
#			BTBV=ball.global_position-global_position
#			# Soluciona que el bot atrape la pelota contra la pared
#			#Si su velocidad es poca (Porque su velocidad es mínima al encerrar a la pelota)
#			if GetMagnitude(linear_velocity)<3.1:
#				#Mientras su distancia contra la pelota no sea mayor a 100 px
#				while GetMagnitude(BTBV)<100:
#					#Se mueve para el lado opuesto con respecto BTBV
#					apply_central_force(-velocity)
#					#Para que no deje de responder se espera un poco
#					await get_tree().create_timer(0.01).timeout
				
	
func hitBall(delta):
	# ballFP= ball future position
		for time in timePrediction:
			ballFP=ball.position+(ball.linear_velocity*time)
			ball.ball_ray_cast.target_position=ballFP-ball.position
			await get_tree().create_timer(0.0000001).timeout
			if ball!=null and ball.ball_ray_cast.is_colliding():
				if ball.ball_ray_cast.get_collider().is_in_group("Player"):
					calculator.kick=false
					break
				elif ball.ball_ray_cast.get_collider().get_parent().name=="WallContainer":
					ballFP=FuturePositionBounce()
			if ball==null:
				break
					
			# Down Corner To Ball Future Position Vector
			var DCTBFPV=ballFP-downCorner.position
			# Up Coner To Ball Future Position Vector
			var UCTBFPV=ballFP-upCorner.position
			var maxAngleToShot=hypotenuseNormalized(DCTBFPV)
			var minAngleToShot=hypotenuseNormalized(UCTBFPV)
			var randomAngleToShotX=randf_range(minAngleToShot.x,maxAngleToShot.x)
			var randomAngleToShotY=randf_range(minAngleToShot.y,maxAngleToShot.y)
			var randomAngleToShot=Vector2(randomAngleToShotX,randomAngleToShotY)
			var positionToShot=ballFP+randomAngleToShot*DTBBS # Distance To Ball Before Shot
			bot_2_ray_cast.target_position=ballFP-position
			if bot_2_ray_cast.is_colliding():
				if bot_2_ray_cast.get_collider().name!="Ball":
					calculator.kick=false
					break
			bot_2_ray_cast_pts.target_position=positionToShot-position
			var px = hypotenuseNormalized(positionToShot-position)
			px*=55
			bot_2_ray_cast_pts.target_position=(positionToShot-position)+px
			if bot_2_ray_cast_pts.is_colliding():
				calculator.kick=false
				break
			# Se fija si al distancia que puede recorrer el bot en función de time es suficiente para llegar a positionToShot
			if GetMagnitude(positionToShot-position)<AOPPSWS*time*0.76 and turboRemaining>0.15:
				calculator.kick=true
				linear_velocity=Vector2(0,0)
				var timer2=2.2
				while positionToShot.distance_to(position)>4:
					var direction=hypotenuseNormalized(positionToShot-position)
					apply_central_force(delta*walkSpeed*direction)
					await get_tree().create_timer(0.0000001).timeout
					timer2-=get_process_delta_time()
					if timer2<=0:
						break
				linear_velocity=Vector2(0,0)
				position=positionToShot
				var timer1=2.2
				while true:
					if GetMagnitude(ball.position-ballFP)/GetMagnitude(ball.linear_velocity)<=0.5934353098:
						var timer=0.3
						while timer>0:
							apply_central_force(delta*hyperTurboSpeed*hypotenuseNormalized(ballFP-position))
							turboRemaining-=delta/1.5
							get_node("TurboBar").ChangeValue(turboRemaining)
							timer-=get_physics_process_delta_time()
							await get_tree().create_timer(0.0000001).timeout
						calculator.kick=false
						break
					await get_tree().create_timer(0.0000001).timeout
					timer1-=delta
					if timer1<=0:
						calculator.kick=false						
						break
				calculator.kick=false						
				break
			else:
				calculator.kick==false
			
		functionCallable=true
func defenseGoal(delta):
	functionCallable2=false
	if ball!=null and GetMagnitude(ball.position-goalCenterVector)<300:
		if turboRemaining>0:
			apply_central_force(hypotenuseNormalized(ball.position-position)*turboSpeed*delta)
			turboRemaining-=get_process_delta_time()/4.5
			get_node("TurboBar").ChangeValue(turboRemaining)
		else:
			apply_central_force(hypotenuseNormalized(ball.position-position)*walkSpeed*delta)
	elif turboRemaining<0.2:
		var whichTurbo=Vector2()
		if position.y<320:
			whichTurbo=turboVector[0]
		else:
			whichTurbo=turboVector[1]
		apply_central_force(hypotenuseNormalized(whichTurbo-position)*walkSpeed*delta)
	elif GetMagnitude(goalCenterVector-position)>10:
		apply_central_force(hypotenuseNormalized(goalCenterVector-position)*walkSpeed*delta)
	functionCallable2=true
