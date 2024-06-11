extends RigidBody2D

@export var walkSpeed=int()
@export var turboSpeed=int()
@export var hyperTurboSpeed=float()
@export var turboRemaining=float()
@onready var down_ray_cast = $DownRayCast
@onready var up_ray_cast = $UpRayCast
@onready var left_ray_cast = $LeftRayCast
@onready var right_ray_cast = $RightRayCast
#@export var dash=float()
var direction=Vector2()
var velocity=Vector2()
var move=true
var cronometer=0.0
@export var positionDestination=Vector2()
var boolean=false
func get_direction(delta):
	#Obtiene un vector unitario
	var direction=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
#	if Input.is_action_pressed("ui_right"):
#		cronometer+=get_process_delta_time()
#	if position.x>=positionDestination.x and boolean==false:
#		print(cronometer)
#		boolean=true
	#Se consulta si el click derecho está siendo apretado y si aún queda turbo para usarlo
	if Input.is_action_pressed("right_click"):
		
		# I:1
		#Multiplica velocity por la velocidad del turbo y se resta el turbo restante
		velocity=direction*turboSpeed*delta
		turboRemaining-=get_process_delta_time()/4.8
		#Llama a la función ChangeValue del TextureProgressVar para cambiar su value
		get_node("TurboBar").ChangeValue(turboRemaining)
		
	#Se consulta si el click izquierdo está siendo apretado y si aún queda Hyperturbo para usarlo
	elif Input.is_action_pressed("left_click") and turboRemaining>=0:
		# I:1
		#Multiplica velocity por la velocidad del turbo y se resta el turbo restante
		velocity=direction*hyperTurboSpeed*delta
		turboRemaining-=get_process_delta_time()/1.5
		#Llama a la función ChangeValue del TextureProgressVar para cambiar su value
		get_node("TurboBar").ChangeValue(turboRemaining)
#	elif Input.is_action_just_pressed("ui_accept") and turboRemaining<=0:
#		apply_central_impulse(direction*dash)
	else:
		#I:2
		#Si no se usa el turbo la velocidad es normal
		velocity=direction*walkSpeed*delta

func _physics_process(delta):
	if move==true:
		#Consigue la dirección y la velocidad a la que se movera el jugador
		get_direction(delta)
		#Se mueve el jugador usando el vector velocity
		apply_central_force(velocity)
