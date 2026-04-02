extends Node2D

# Aqui vamos colocar o Zombie.tscn
export(PackedScene) var zombie_scene

func _on_Timer_timeout():
	_spawn_zombie()

func _spawn_zombie():
	if zombie_scene == null:
		print("Erro: Arraste o Zombie.tscn para o campo Zombie Scene no Inspetor!")
		return
		
	# Cria a cópia
	var new_zombie = zombie_scene.instance()
	
	# Definicao da posicao (Ta a mesma do Spawner)
	new_zombie.global_position = global_position
	
	# Adiciona ao mundo (Fase1)
	get_parent().add_child(new_zombie)
