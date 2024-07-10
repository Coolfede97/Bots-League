extends Node2D

var bot2 = ResourceLoader.load("res://Bots/2/bot2.tscn")
var bots = [bot2]
var ball: RigidBody2D
@export var ballExplosion: PackedScene
@export var ballInstance: PackedScene
@export var bot2Instance: PackedScene
@export var playerIPosition=Vector2() #Player Initial Position
@export var botIPosition=Vector2() # Bot Initial Position
@export var resetSpeed=float()
@export var PlayerReference: RigidBody2D
@export var botName=String()
@export var bot: RigidBody2D
var playerIsInIP=bool() # Player Is In Initial Position
var botIsInIP=bool() # Bot Is In Initial Position
@export var ready_go: Label
@export var PlayerScore: Label
@export var BotScore: Label

func _physics_process(delta):
	if (get_parent().get_node("Ball")!=null):
		bot.ball=get_parent().get_node("Ball")

func _ready():
	print(bots[0])
	PlayerReference.move=false
	bot.move=false
	await get_tree().create_timer(0.5).timeout
	ready_go.text="READY"
	while ready_go.modulate.a<0.7:
		ready_go.modulate.a=lerp(ready_go.modulate.a, 1.2 , 1.0*get_process_delta_time())
		await get_tree().create_timer(0.001).timeout
	while ready_go.modulate.a>0.001:
		ready_go.modulate.a=lerp(ready_go.modulate.a, -1.2 , 1.0*get_process_delta_time())
		await get_tree().create_timer(0.0001).timeout
	ready_go.modulate.a=0
	await get_tree().create_timer(0.2).timeout
	ready_go.text="¡GO!"
	PlayerReference.move=true
	bot.move=true
	while ready_go.modulate.a<0.8:
		ready_go.modulate.a=lerp(ready_go.modulate.a, 1.0 , 4*get_process_delta_time())
		await get_tree().create_timer(0.001).timeout
	while ready_go.modulate.a>0.1:
		ready_go.modulate.a=lerp(ready_go.modulate.a, -1.0 , 0.5*get_process_delta_time())
		await get_tree().create_timer(0.0001).timeout
	ready_go.modulate.a=0 

#Instancia particulas en la posición de la pelota y hacia tal dirección
# Y hace más cosas, muchas mas cosas...
func Goal(ballPosition, direction):
	#Instancia particulas de la explosión del gol
	var ballExplosionParticles=ballExplosion.instantiate()
	ballExplosionParticles.position=ballPosition
	ballExplosionParticles.process_material.direction=Vector3(direction,0,0)
	self.add_child(ballExplosionParticles)
	if direction==1:
		BotScore.text = str(int(BotScore.text)+1)
	else:
		PlayerScore.text = str(int(PlayerScore.text)+1)
	# Vectores que indican que un gol ha ocurrido
	var ballPGP=get_parent().get_node("Ball").PGP # Player Goal Position
	var ballBGP=get_parent().get_node("Ball").BGP # Bot Goal Position
	# Elimina a la pelota de la escena
	get_parent().get_node("Ball").queue_free()
	await get_tree().create_timer(1).timeout
	# Impide que los jugadores se muevan
	PlayerReference.move=false
	bot.move=false
	await get_tree().create_timer(1).timeout
	
	# Mueve a los jugadores a sus posiciones iniciales
	while PlayerReference.position!=playerIPosition or bot.position!=botIPosition:
		# Player Position To Player Initial Position Vector
		var PPTPIPV = playerIPosition-PlayerReference.position
		# Bot Position To Bot Initial Position Vector
		var BPTBIPV = botIPosition-bot.position
		if PlayerReference.position!=playerIPosition:
			PlayerReference.apply_central_force(resetSpeed*hypotenuseNormalized(PPTPIPV)*get_process_delta_time())
			if GetMagnitude(PPTPIPV)<=7:
				PlayerReference.linear_velocity=Vector2(0,0)
				PlayerReference.angular_velocity=0.0
				PlayerReference.position=playerIPosition
				playerIsInIP=true
				
		if bot.position!=botIPosition:
			bot.apply_central_force(resetSpeed*hypotenuseNormalized(BPTBIPV)*get_process_delta_time())
			if GetMagnitude(BPTBIPV)<=7:
				bot.linear_velocity=Vector2(0,0)
				bot.angular_velocity=0.0
				bot.position=botIPosition
				botIsInIP=true
				
		if botIsInIP and playerIsInIP:
			break
		await get_tree().create_timer(0.0001).timeout
		
	botIsInIP=false
	playerIsInIP=false
	if BotScore.text=="7":
		botWins()
	elif PlayerScore.text=="1":
		playerWins()
	await get_tree().create_timer(0.5).timeout
	# Instancia una nueva pelota
	var nextBall=ballInstance.instantiate()
	nextBall.position=Vector2(576,324)
	nextBall.PGP=ballPGP
	nextBall.BGP=ballBGP
	nextBall.ball_ray_cast = nextBall.GetRayCast("BallRayCast")
	nextBall.down_ray_cast = nextBall.GetRayCast("DownRayCast")
	nextBall.up_ray_cast = nextBall.GetRayCast("UpRayCast")
	nextBall.left_ray_cast = nextBall.GetRayCast("LeftRayCast")
	nextBall.right_ray_cast = nextBall.GetRayCast("RightRayCast")
	ball=nextBall
	bot.get_node("Calculator").ball=ball
	get_parent().add_child(nextBall)
	bot.ball=ball
	ball.GetBot()
	
	# Resetea el turbo de los jugadores
	while not bot.turboRemaining>=0.5 or not PlayerReference.turboRemaining>=0.5:
		if bot.turboRemaining<0.5:
			bot.turboRemaining = lerp(bot.turboRemaining,1.0,0.01)
			bot.get_node("TurboBar").ChangeValue(bot.turboRemaining)
		else:
			bot.turboRemaining=0.5
		if PlayerReference.turboRemaining<0.5:
			PlayerReference.turboRemaining = lerp(PlayerReference.turboRemaining,1.0,0.01)
			PlayerReference.get_node("TurboBar").ChangeValue(PlayerReference.turboRemaining)
		else:
			PlayerReference.turboRemaining=0.5
		await get_tree().create_timer(0.01).timeout
		
	await get_tree().create_timer(1).timeout
	
	ready_go.text="READY"
	while ready_go.modulate.a<0.7:
		ready_go.modulate.a=lerp(ready_go.modulate.a, 1.0 , 1.0*get_process_delta_time())
		await get_tree().create_timer(0.001).timeout
	while ready_go.modulate.a>0.001:
		ready_go.modulate.a=lerp(ready_go.modulate.a, -1.0 , 1.0*get_process_delta_time())
		await get_tree().create_timer(0.0001).timeout
	ready_go.modulate.a=0
	await get_tree().create_timer(0.2).timeout
	ready_go.text="¡GO!"
	PlayerReference.move=true
	bot.move=true
	while ready_go.modulate.a<0.8:
		ready_go.modulate.a=lerp(ready_go.modulate.a, 1.0 , 4*get_process_delta_time())
		await get_tree().create_timer(0.001).timeout
	while ready_go.modulate.a>0.1:
		ready_go.modulate.a=lerp(ready_go.modulate.a, -1.0 , 0.5*get_process_delta_time())
		await get_tree().create_timer(0.0001).timeout
	ready_go.modulate.a=0 

func playerWins():
	var nextBot = bots[0].instantiate()
	nextBot.position=bot.position
	nextBot.upCorner=get_parent().get_node("GoalsContainer").get_node("UpCorner")
	nextBot.downCorner=get_parent().get_node("GoalsContainer").get_node("DownCorner")
	var explosion=bot2Instance.instantiate()
	explosion.position=bot.position
	add_child(explosion)
	bot.queue_free()
	bot=nextBot
	get_parent().add_child(nextBot)
	bots.remove_at(0)


func botWins():
	print("GANEEE")

# Buscar en bot1
func hypotenuseNormalized(vector):
	var hyp=sqrt(vector.x**2+vector.y**2)
	var vectorNormalized=vector/hyp
	return vectorNormalized

#Buscar en bot1
func GetMagnitude(vector):
	var distance=sqrt(vector.x**2+vector.y**2)
	return distance
	
func ReadyGo():
	pass
	
