extends RigidBody2D

@export var PGP=float() #Player Goal Position  Posición de la pelota que indica que le hicieron un gol al jugador
@export var BGP=float() #Bot Goal Position
@onready var ball_ray_cast = GetRayCast("BallRayCast")
@onready var down_ray_cast = GetRayCast("DownRayCast")
@onready var up_ray_cast = GetRayCast("UpRayCast")
@onready var left_ray_cast = GetRayCast("LeftRayCast")
@onready var right_ray_cast = GetRayCast("RightRayCast")
@onready var bot=GetBot()

func GetRayCast(name):
	return get_node(name)
	
#Detecta cuando la pelota entra en alguno de los dos arcos. 
#Cuando lo hace, llama a una función de GoalManager pasandole la posición de la pelota como argumento.
#También pasa la dirección a la que debe apuntar la explosión de particulas
func _physics_process(delta):	
	down_ray_cast.global_rotation=0
	up_ray_cast.global_rotation=0
	left_ray_cast.global_rotation=0
	right_ray_cast.global_rotation=0
	ball_ray_cast.global_rotation=0
	if position.x<=PGP:
		get_parent().get_node("GoalManager").Goal(position,1)
		await get_tree().create_timer(2).timeout
	elif position.x>=BGP:
		get_parent().get_node("GoalManager").Goal(position,-1)
		await get_tree().create_timer(2).timeout
func GetBot():
	for node in get_parent().get_children():
		if node.is_in_group("Bots"):
			return node
			

