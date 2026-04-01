extends KinematicBody2D



export var speed = 100         # Velocidade do zumbi
export var detect_radius = 400 # Raio de visão
export var damage = 10         # Dano que o zumbi causa

var target = null              # Referência ao Player
var update_tick = 0

func _physics_process(_delta):
	# Otmização feita para manter o jogo a 30 fps
	update_tick += 1
	if update_tick >= 30:
		update_tick = 0
		_update_ai_logic()
	
	_move_along_path()

func _update_ai_logic():
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		var dist = global_position.distance_to(p.global_position)
		
		if dist <= detect_radius:
			target = p
		else:
			target = null

func _move_along_path():
	if target != null:
		var distance_to_target = global_position.distance_to(target.global_position)
		
		if distance_to_target > 30:
			var direction = (target.global_position - global_position).normalized()
			move_and_slide(direction * speed)
		else:
			_atacar_player()

func _atacar_player():
	# tem que ser feito...

	pass
