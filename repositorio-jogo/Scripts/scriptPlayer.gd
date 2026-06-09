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

var tiles_navegaveis = {}

var tsp_ativo = false
var tsp_caminhos = []
var tsp_ordem = []
var tsp_pulso = 0.0
var tsp_pulso_vel = 2.0  # pulses per second

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
	if tsp_ativo:
		tsp_pulso = fmod(tsp_pulso + delta * tsp_pulso_vel, 1.0)
		update()

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
	if event is InputEventKey and event.pressed and event.scancode == KEY_T:
		tsp_ativo = !tsp_ativo
		if tsp_ativo:
			_calcular_tsp()
		else:
			tsp_caminhos = []
			tsp_ordem = []
			update()

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

# ================= TSP =================
func _ordenar_por_distancia_player(a, b) -> bool:
	return global_position.distance_squared_to(a.global_position) < \
	       global_position.distance_squared_to(b.global_position)

func _calcular_tsp():
	var itens = []
	for no in get_tree().get_nodes_in_group("ItemChao"):
		if is_instance_valid(no) and not no.coletado:
			itens.append(no)

	if itens.size() == 0:
		tsp_ativo = false
		return

	if itens.size() > 8:
		itens.sort_custom(self, "_ordenar_por_distancia_player")
		itens = itens.slice(0, 7)  # keep first 8 (indices 0..7)

	var player_tile = tilemap_nav.world_to_map(global_position)
	if not _e_navegavel(player_tile):
		player_tile = _navegavel_mais_proximo(player_tile)

	var tiles_itens = []
	for item in itens:
		var t = tilemap_nav.world_to_map(item.global_position)
		if not _e_navegavel(t):
			t = _navegavel_mais_proximo(t)
		tiles_itens.append(t)

	# Nós na matriz: índice 0 = jogador, 1..n = itens
	var n_itens = tiles_itens.size()
	var todos = [player_tile] + tiles_itens
	var n_total = todos.size()

	var dist = {}
	var caminhos_cache = {}
	for i in range(n_total):
		for j in range(n_total):
			if i == j:
				dist[str(i) + "," + str(j)] = 0
				caminhos_cache[str(i) + "," + str(j)] = []
				continue
			var p = _astar(todos[i], todos[j])
			if p.size() == 0:
				dist[str(i) + "," + str(j)] = 999999
			else:
				dist[str(i) + "," + str(j)] = p.size() - 1
			caminhos_cache[str(i) + "," + str(j)] = p

	var ordem_indices
	if n_itens <= 15:
		ordem_indices = _held_karp(dist, n_itens)
	else:
		ordem_indices = _vizinho_mais_proximo(dist, n_itens)

	tsp_caminhos = []
	tsp_ordem = []
	var anterior = 0  # índice do jogador na matriz
	for idx in ordem_indices:
		var mat_idx = idx + 1  # +1 porque índice 0 é o jogador
		var key = str(anterior) + "," + str(mat_idx)
		tsp_caminhos.append(caminhos_cache[key])
		tsp_ordem.append(itens[idx])
		anterior = mat_idx

	update()

func _held_karp(dist: Dictionary, n: int) -> Array:
	# dp[mask_str + "," + str(node)] = custo mínimo para visitar os nós em mask
	# começando do nó 0 (jogador) e terminando em node (índice de item 1..n)
	var dp = {}
	var pai = {}

	for i in range(1, n + 1):
		var key = str(1 << (i - 1)) + "," + str(i)
		dp[key] = dist.get(str(0) + "," + str(i), 999999)
		pai[key] = 0

	for tamanho in range(2, n + 1):
		for mask in range(1, 1 << n):
			if _contar_bits(mask) != tamanho:
				continue
			for ultimo in range(1, n + 1):
				if not (mask & (1 << (ultimo - 1))):
					continue
				var mask_sem_ultimo = mask ^ (1 << (ultimo - 1))
				var melhor_custo = 999999
				var melhor_anterior = -1
				for anterior in range(1, n + 1):
					if anterior == ultimo:
						continue
					if not (mask_sem_ultimo & (1 << (anterior - 1))):
						continue
					var custo_anterior = dp.get(str(mask_sem_ultimo) + "," + str(anterior), 999999)
					var aresta = dist.get(str(anterior) + "," + str(ultimo), 999999)
					if custo_anterior < 999999 and aresta < 999999:
						var total = custo_anterior + aresta
						if total < melhor_custo:
							melhor_custo = total
							melhor_anterior = anterior
				var key = str(mask) + "," + str(ultimo)
				dp[key] = melhor_custo
				pai[key] = melhor_anterior

	var mask_completo = (1 << n) - 1
	var melhor_final = 999999
	var ultimo_no = -1
	for i in range(1, n + 1):
		var custo = dp.get(str(mask_completo) + "," + str(i), 999999)
		if custo < melhor_final:
			melhor_final = custo
			ultimo_no = i

	if ultimo_no == -1:
		return _vizinho_mais_proximo(dist, n)

	var caminho_tsp = []
	var mask_atual = mask_completo
	var no_atual = ultimo_no
	while no_atual != 0:
		caminho_tsp.insert(0, no_atual - 1)
		var key = str(mask_atual) + "," + str(no_atual)
		var anterior = pai.get(key, 0)
		if anterior == 0:
			break
		mask_atual = mask_atual ^ (1 << (no_atual - 1))
		no_atual = anterior

	return caminho_tsp

func _contar_bits(n: int) -> int:
	var conta = 0
	while n > 0:
		conta += n & 1
		n >>= 1
	return conta

func _vizinho_mais_proximo(dist: Dictionary, n: int) -> Array:
	var visitados = {}
	var ordem = []
	var atual = 0  # começa no jogador
	for _passo in range(n):
		var melhor_custo = 999999
		var melhor_idx = -1
		for i in range(1, n + 1):
			if visitados.has(i):
				continue
			var custo = dist.get(str(atual) + "," + str(i), 999999)
			if custo < melhor_custo:
				melhor_custo = custo
				melhor_idx = i
		if melhor_idx == -1:
			break
		visitados[melhor_idx] = true
		ordem.append(melhor_idx - 1)
		atual = melhor_idx
	return ordem

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
				tiles_navegaveis[Vector2(x, y)] = true

func _e_navegavel(celula):
	return tiles_navegaveis.has(celula)

func _vizinhos(celula):
	var resultado = []
	for direcao in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:
		var vizinho = celula + direcao
		if _e_navegavel(vizinho):
			resultado.append(vizinho)
	return resultado

func _navegavel_mais_proximo(celula):
	var melhor = tiles_navegaveis.keys()[0]
	var distancia = celula.distance_squared_to(melhor)
	for tile in tiles_navegaveis.keys():
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
	if tsp_ativo and tsp_caminhos.size() > 0:
		var alpha_base = 0.4 + 0.6 * sin(tsp_pulso * PI)

		# Draw A* path segments with radar glow effect
		for seg in tsp_caminhos:
			if seg.size() < 2:
				continue
			for i in range(seg.size() - 1):
				var a = tilemap_nav.map_to_world(seg[i]) + Vector2(tamanho_grid / 2, tamanho_grid / 2) - global_position
				var b = tilemap_nav.map_to_world(seg[i + 1]) + Vector2(tamanho_grid / 2, tamanho_grid / 2) - global_position
				# Outer glow (wide, transparent)
				draw_line(a, b, Color(0, 1, 0.3, 0.15 * alpha_base), 8)
				# Mid glow
				draw_line(a, b, Color(0, 1, 0.3, 0.3 * alpha_base), 4)
				# Core line
				draw_line(a, b, Color(0.6, 1, 0.6, alpha_base), 2)

		# Radar ping circles at each item stop (expanding ring effect)
		for i in range(tsp_ordem.size()):
			var no = tsp_ordem[i]
			if not is_instance_valid(no):
				continue
			var pos = no.global_position - global_position

			# Phase offset per item so they pulse at different times
			var fase = fmod(tsp_pulso + i * 0.3, 1.0)
			var raio_externo = 6 + 10 * fase
			var alpha_anel = (1.0 - fase) * alpha_base

			# Expanding ring
			draw_circle(pos, raio_externo, Color(0, 1, 0.3, alpha_anel * 0.4))
			# Static core dot
			draw_circle(pos, 5, Color(0, 0, 0, 0.8))
			draw_circle(pos, 4, Color(0, 1, 0.3, 1.0))



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
		
