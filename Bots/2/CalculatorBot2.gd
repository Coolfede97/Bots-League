extends Node2D

var functionCallable=true
var cronometer: float
@export var ball: RigidBody2D
@export var bot : RigidBody2D
@export var walkSpeed=int()
@export var turboSpeed=int()
@export var hyperTurboSpeed=float() 
@export var turboVector=[Vector2(),Vector2()]
var touchTurbo=false
var lookingForturbo=false
var kick=false
var destrabando=false
#Obtiene la magnitud de un vector dado
func GetMagnitude(vector):
	var distance=sqrt(vector.x**2+vector.y**2)
	return distance

#Obtiene el vector normalizado del vector dado
func hypotenuseNormalized(vector):
	var hyp=sqrt(vector.x**2+vector.y**2)
	var vectorNormalized=vector/hyp
	return vectorNormalized

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
#	print(localballFP)
	ball.ball_ray_cast.target_position=localballFP-ball.position
	return localballFP
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
	touchTurbo=false
	lookingForturbo=false
	kick=false
func _physics_process(delta):
	if bot.linear_velocity==Vector2(0,0) and bot.isOfensive:
		cronometer+=get_process_delta_time()
		if cronometer>5:
			resetScript()
	else:
		cronometer=0	
	if functionCallable and !kick and bot.isOfensive==true and !destrabando:
		notAbleToKick(delta)
func notAbleToKick(delta):
	functionCallable=false
	if bot.position.x-ball.position.x>0 and kick==false:
		if ball.linear_velocity.x<0 or ball.position.distance_to(bot.position)>250:
			bot.apply_central_force(hypotenuseNormalized(bot.ballFP-bot.position)*walkSpeed*delta)
		else:
			bot.apply_central_force(hypotenuseNormalized(ball.position-bot.position)*walkSpeed*delta)
	elif kick==false:
		lookingForturbo=true
		bot.turboRemaining-=0.01
		var whichTurbo=Vector2()
		if bot.position.y<320:
			whichTurbo=turboVector[0]
		else:
			whichTurbo=turboVector[1]
		while bot.turboRemaining!=0.5 and !touchTurbo:
			if bot.turboRemaining>0 and !touchTurbo:
				bot.apply_central_force(hypotenuseNormalized(whichTurbo-bot.position)*turboSpeed*delta)
				bot.turboRemaining-=delta/4.5
				bot.get_node("TurboBar").ChangeValue(bot.turboRemaining)
			elif !touchTurbo:
				bot.apply_central_force(hypotenuseNormalized(whichTurbo-bot.position)*walkSpeed*delta)
			await get_tree().create_timer(0.0000001).timeout
		await get_tree().create_timer(0.001).timeout
		touchTurbo=false
		lookingForturbo=false
	functionCallable=true
