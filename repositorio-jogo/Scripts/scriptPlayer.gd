extends KinematicBody2D

# ================= CONFIGURAÇÃO =================
var velocidade = 200
var tamanho_grid = 16
var life = 10

var caminho = []
var indice_caminho = 0
var seguindo_caminho = false

var disparo = preload("res://Instantiables/Disparo.tscn")

onready var tilemap_nav = $"../TileMapNavigation"
onready var tilemap_obs = $"../TileMapObstaculos"

var tiles_navegaveis = []

# ================= PRONTO =================
func _ready():
	_configurar_tiles()

# ================= FÍSICA =================
func _physics_process(delta):
	_verificar_movimento(delta)
	_verificar_coleta()
	disparar()
	exibir_hud()
	verificar_morte()

func _verificar_movimento(delta):
	if _tem_input_teclado():
		_cancelar_caminho()
		_mover_teclado()
	elif seguindo_caminho:
		_seguir_caminho(delta)

# ================= INPUT =================
func _input(event):
	if event is InputEventMouseButton and event.pressed and Input.is_key_pressed(KEY_SHIFT):
		_clicar_destino()

func _clicar_destino():
	var mouse_pos = get_global_mouse_position()
	var inicio = tilemap_nav.world_to_map(global_position)
	var destino = tilemap_nav.world_to_map(mouse_pos)

	if not _e_navegavel(inicio):
		inicio = _navegavel_mais_proximo(inicio)

	if not _e_navegavel(destino):
		return

	caminho = _astar(inicio, destino)
	indice_caminho = 0
	seguindo_caminho = caminho.size() > 0
	update()

# ================= MOVIMENTO =================
func _tem_input_teclado():
	return (
		Input.is_action_pressed("d") or
		Input.is_action_pressed("a") or
		Input.is_action_pressed("w") or
		Input.is_action_pressed("s")
	)

func _cancelar_caminho():
	seguindo_caminho = false
	caminho = []
	update()

func _mover_teclado():
	var vel = Vector2.ZERO
	if Input.is_action_pressed("d"):
		vel.x = 1
	elif Input.is_action_pressed("a"):
		vel.x = -1
	elif Input.is_action_pressed("s"):
		vel.y = 1
	elif Input.is_action_pressed("w"):
		vel.y = -1
	
	if vel != Vector2.ZERO:
		move_and_slide(vel.normalized() * velocidade)

func _seguir_caminho(delta):
	if indice_caminho >= caminho.size():
		seguindo_caminho = false
		return

	var tile_alvo = caminho[indice_caminho]
	var alvo = tilemap_nav.map_to_world(tile_alvo) + Vector2(tamanho_grid / 2, tamanho_grid / 2)
	var direcao = alvo - global_position

	if direcao.length() < 2:
		move_and_slide(direcao.normalized() * velocidade)
		indice_caminho += 1
		return

	move_and_slide(direcao.normalized() * velocidade)
	update()

# ================= PATHFINDING =================
func _astar(inicio, destino):
	var abertos = [inicio]
	var veio_de = {}
	var custo_g = {inicio: 0}
	var custo_f = {inicio: inicio.distance_to(destino)}

	while abertos.size() > 0:
		var atual = abertos[0]
		for n in abertos:
			if custo_f.get(n, INF) < custo_f.get(atual, INF):
				atual = n

		if atual == destino:
			return _reconstruir_caminho(veio_de, atual)

		abertos.erase(atual)
		for vizinho in _vizinhos(atual):
			var novo_g = custo_g.get(atual, INF) + 1
			if novo_g < custo_g.get(vizinho, INF):
				veio_de[vizinho] = atual
				custo_g[vizinho] = novo_g
				custo_f[vizinho] = novo_g + vizinho.distance_to(destino)
				if not vizinho in abertos:
					abertos.append(vizinho)
	return []

func _reconstruir_caminho(veio_de, atual):
	var caminho_final = [atual]
	while atual in veio_de:
		atual = veio_de[atual]
		caminho_final.insert(0, atual)
	return caminho_final

# ================= TILES =================
func _configurar_tiles():
	tiles_navegaveis.clear()
	var area = tilemap_nav.get_used_rect()
	for x in range(area.position.x, area.position.x + area.size.x):
		for y in range(area.position.y, area.position.y + area.size.y):
			if tilemap_nav.get_cell(x, y) != -1 and tilemap_obs.get_cell(x, y) == -1:
				tiles_navegaveis.append(Vector2(x, y))

func _e_navegavel(celula):
	return celula in tiles_navegaveis

func _vizinhos(celula):
	var resultado = []
	for direcao in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:
		var vizinho = celula + direcao
		if _e_navegavel(vizinho):
			resultado.append(vizinho)
	return resultado

func _navegavel_mais_proximo(celula):
	var melhor = tiles_navegaveis[0]
	var distancia = celula.distance_squared_to(melhor)
	for tile in tiles_navegaveis:
		var d = celula.distance_squared_to(tile)
		if d < distancia:
			distancia = d
			melhor = tile
	return melhor

# ================= INVENTÁRIO =================
func _verificar_coleta():
	for i in get_slide_count():
		var colisao = get_slide_collision(i)
		if colisao == null:
			continue
		var objeto = colisao.collider
		if is_instance_valid(objeto) and objeto.is_in_group("ItemChao") and not objeto.coletado:
			objeto.coletado = true
			var dados = objeto.coletar()
			_adicionar_ao_inventario(dados)
			objeto.queue_free()

func _adicionar_ao_inventario(dados):
	var slots = get_tree().get_nodes_in_group("Slots")
	var sobra = dados.quantidade
	for slot in slots:
		if sobra <= 0:
			break
		sobra = slot.tentar_adicionar_item(dados.id, dados.textura, sobra)
	if sobra > 0:
		print("Inventário cheio! Sobrou: ", sobra)

# ================= DESENHO =================
func _draw():
	for i in range(caminho.size() - 1):
		var a = tilemap_nav.map_to_world(caminho[i])     + Vector2(tamanho_grid / 2, tamanho_grid / 2)
		var b = tilemap_nav.map_to_world(caminho[i + 1]) + Vector2(tamanho_grid / 2, tamanho_grid / 2)
		draw_line(a - global_position, b - global_position, Color.green, 2)



func disparar():
	if Input.is_action_just_pressed("shoot"):
		var novodisparo = disparo.instance()
		novodisparo.global_position = global_position
		
		# Calcula a direção até o mouse
		var direcao_mouse = (get_global_mouse_position() - global_position).normalized()
		novodisparo.direcao = direcao_mouse
		
		get_parent().add_child(novodisparo)


func tomar_dano(damage):
	life -= damage


func exibir_hud():
	$ProgressBar.value = life
	$ProgressBar.max_value = 10
	
func verificar_morte():
	if life <= 0:
		get_tree().change_scene("res://Instantiables/CenaDeDerrota.tscn")
		
