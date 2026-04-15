extends Node2D

# Caminho para a cena do inimigo
var Inimigo = preload("res://Instantiables/Enemy.tscn")

# Total máximo de inimigos que podem spawnar
var max_spawn = 10

# Contador de quantos inimigos já foram spawnados
var inimigos_spawnados = 0

# Distancia aleatória mínima para não empilhar inimigos
var spawn_range = 20

func _ready():
	# Timer começa parado, só inicia quando o player entra
	$Timer.stop()

func _on_Timer_timeout():
	# Se já spawnou todos, para o Timer
	if inimigos_spawnados >= max_spawn:
		$Timer.stop()
		return

	# Cria a instância do inimigo
	var inimigo = Inimigo.instance()
	get_parent().add_child(inimigo)

	# Posição aleatória mínima em volta do spawner para não empilhar
	var offset = Vector2(
		rand_range(-spawn_range, spawn_range),
		rand_range(-spawn_range, spawn_range)
	)
	inimigo.global_position = global_position + offset

	inimigos_spawnados += 1

# Quando o player entra na Area2D, inicia o spawn
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		# Só inicia o Timer se ainda não spawnou todos os 10
		if inimigos_spawnados < max_spawn and $Timer.is_stopped():
			$Timer.start()
