extends KinematicBody2D

# ================= CONFIGURAÇÃO =================
var velocidade = 120
var life = 5
var tamanho_grid = 16

var jogador = null
var perseguindo = false

var caminho = []
var indice_caminho = 0

onready var tilemap_nav = $"../TileMapNavigation"
onready var tilemap_obs = $"../TileMapObstaculos"

var tiles_navegaveis = []

var timer_recalculo = 0.0
const INTERVALO_RECALCULO = 0.3 

# ================= PRONTO =================
func _ready():
	jogador = get_parent().get_node("Player")
	_configurar_tiles()


func _process(delta):
	verificar_morte()
	exibir_hud()
	
	verificar_player_dar_dano()
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

# ================= A* =================
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

func _vizinhos(celula):
	var resultado = []
	for direcao in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:
		var vizinho = celula + direcao
		if _e_navegavel(vizinho):
			resultado.append(vizinho)
	return resultado

func _reconstruir_caminho(veio_de, atual):
	var caminho_final = [atual]
	while atual in veio_de:
		atual = veio_de[atual]
		caminho_final.insert(0, atual)
	return caminho_final

func _navegavel_mais_proximo(celula):
	var melhor = tiles_navegaveis[0]
	var distancia = celula.distance_squared_to(melhor)
	for tile in tiles_navegaveis:
		var d = celula.distance_squared_to(tile)
		if d < distancia:
			distancia = d
			melhor = tile
	return melhor

# ================= FÍSICA =================
func _physics_process(delta):
	if not perseguindo:
		return

	# Recalcula o caminho periodicamente enquanto persegue
	timer_recalculo += delta
	if timer_recalculo >= INTERVALO_RECALCULO:
		timer_recalculo = 0.0
		_recalcular_caminho()

	_seguir_caminho(delta)
	

func _seguir_caminho(delta):
	if indice_caminho >= caminho.size():
		_recalcular_caminho()
		return

	var tile_alvo = caminho[indice_caminho]
	var alvo = tilemap_nav.map_to_world(tile_alvo) + Vector2(tamanho_grid / 2, tamanho_grid / 2)
	var direcao = alvo - global_position

	if direcao.length() < 2:
		indice_caminho += 1
		return

	move_and_slide(direcao.normalized() * velocidade)

func _recalcular_caminho():
	if jogador == null:
		return

	var inicio  = tilemap_nav.world_to_map(global_position)
	var destino = tilemap_nav.world_to_map(jogador.global_position)

	if not _e_navegavel(inicio):
		inicio = _navegavel_mais_proximo(inicio)
	if not _e_navegavel(destino):
		destino = _navegavel_mais_proximo(destino)

	# Não recalcula se o destino não mudou
	if caminho.size() > 0 and caminho[caminho.size() - 1] == destino:
		return

	caminho = _astar(inicio, destino)
	
	# ✅ Pula o primeiro tile (é onde o inimigo já está)
	indice_caminho = 1 if caminho.size() > 1 else 0

# ================= DETECÇÃO =================
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		perseguindo = true
		_recalcular_caminho()

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		perseguindo = false
		caminho = []


func tomar_dano(damage):
	life -= damage
	
func verificar_morte():
	if life <= 0:
		print("Inimigo Morto")
		queue_free()
		
func exibir_hud():
	$ProgressBar.value = life
	$ProgressBar.max_value = 5

func verificar_player_dar_dano():
	var info = get_last_slide_collision()
	if info and is_instance_valid(info.collider):
		if "Player" in info.collider.name:
			info.collider.tomar_dano(5)
			queue_free()
