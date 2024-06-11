extends TextureProgressBar

# 0.5-turboRemaining
var turboNeeded=0
var turboAdded=0

#Cambia el value de este TextureProgressBar (El value determina que tan lleno está la barra)
func ChangeValue(turboRemaining):
	#El Turbo máximo que pueden poseer los jugadores es de 0.5 pero para manipular Value comodamente se multiplica *1000
	value=turboRemaining*1000

func AddTurbo(body,turboPosition):
	if body.is_in_group("Bots"):
		body.get_node("Calculator").touchTurbo=true
	turboNeeded=0.5-body.turboRemaining
	#El turboRemaining de los jugador vuelve al máximo
	while turboAdded!=turboNeeded:
		turboAdded+=0.04
		body.turboRemaining+=0.04
		ChangeValue(body.turboRemaining)
		if turboAdded>turboNeeded:
			turboAdded=turboNeeded
			if body.turboRemaining>0.5:
				body.turboRemaining=0.5

		await get_tree().create_timer(0.00005).timeout
	turboAdded=0
	turboNeeded=0
