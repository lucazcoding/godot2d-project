extends TextureRect

# ================= CONFIG =================
const USAR_HASH := false  # true = hash | false = sort_custom (quicksort)

# ================= INVENTÁRIO =================
func _ready():
	visible = false

func _process(_delta):
	if Input.is_action_just_pressed("abrir_inventario"):
		visible = !visible
		if visible:
			ordenar_slots()

# ================= ORDENAÇÃO =================
func ordenar_slots() -> void:
	var slots = get_tree().get_nodes_in_group("Slots")
	var total_slots: int = slots.size()
	var lista_itens := []

	# 1. Lê e limpa cada slot ocupado
	for slot in slots:
		if slot.id_atual != "":
			var dados = BancoDeItens.itens[slot.id_atual]
			lista_itens.append({
				"id":         slot.id_atual,
				"categoria":  dados.categoria,
				"nome":       dados.nome,
				"textura":    slot.get_node("Item_Sprite").texture,
				"quantidade": int(slot.get_node("Amount").text) if slot.get_node("Amount").text != "" else 1
			})
			slot.id_atual = ""
			slot.get_node("Item_Sprite").texture = null
			slot.get_node("Amount").text = ""
			slot.arrastando = false

	# 2. Distribui conforme o modo ativo
	if USAR_HASH:
		_distribuir_com_hash(lista_itens, slots, total_slots)
	else:
		_quicksort(lista_itens, 0, lista_itens.size() - 1)
		for i in range(lista_itens.size()):
			_preencher_slot(slots[i], lista_itens[i])

# ================= LÓGICA HASH =================
func _hash_id(id: String, total: int) -> int:
	var soma := 0
	for byte in id.to_utf8():
		soma += byte
	return soma % total

func _distribuir_com_hash(itens: Array, slots: Array, total: int) -> void:
	# Array de controle: marca quais slots já foram ocupados nessa distribuição
	var ocupado := []
	ocupado.resize(total)
	ocupado.fill(false)

	for item in itens:
		var idx: int = _hash_id(item.id, total)
		var inserido := false

		# Sondagem linear: tenta idx, idx+1, idx+2... até achar slot vazio
		for tentativa in range(total):
			var pos: int = (idx + tentativa) % total
			if not ocupado[pos]:
				_preencher_slot(slots[pos], item)
				ocupado[pos] = true
				inserido = true
				break

		# Se percorreu todos os slots sem achar vazio, inventário está cheio
		if not inserido:
			print("Inventário cheio! Item não inserido: ", item.id)

# ================= PREENCHER SLOT =================
func _preencher_slot(slot, item: Dictionary) -> void:
	slot.id_atual = item.id
	slot.get_node("Item_Sprite").texture = item.textura
	slot.get_node("Amount").text = str(item.quantidade) if item.quantidade > 1 else ""

# ================= QUICKSORT =================
func _quicksort(arr: Array, baixo: int, alto: int) -> void:
	if baixo < alto:
		var p = _particionar(arr, baixo, alto)
		_quicksort(arr, baixo, p - 1)
		_quicksort(arr, p + 1, alto)

func _particionar(arr: Array, baixo: int, alto: int) -> int:
	# Pivô mediano de três: arr[baixo], arr[meio], arr[alto]
	var meio = baixo + (alto - baixo) / 2

	# Ordena os três para encontrar a mediana
	if comparar_itens(arr[meio], arr[baixo]):
		var tmp = arr[baixo]; arr[baixo] = arr[meio]; arr[meio] = tmp
	if comparar_itens(arr[alto], arr[baixo]):
		var tmp = arr[baixo]; arr[baixo] = arr[alto]; arr[alto] = tmp
	if comparar_itens(arr[meio], arr[alto]):
		var tmp = arr[alto]; arr[alto] = arr[meio]; arr[meio] = tmp

	# arr[alto] é agora o pivô mediano
	var pivo = arr[alto]
	var i = baixo - 1

	for j in range(baixo, alto):
		if comparar_itens(arr[j], pivo) or arr[j].nome == pivo.nome:
			i += 1
			var tmp = arr[i]; arr[i] = arr[j]; arr[j] = tmp

	var tmp = arr[i + 1]; arr[i + 1] = arr[alto]; arr[alto] = tmp
	return i + 1

# ================= COMPARAÇÃO (quicksort) =================
func comparar_itens(a, b) -> bool:
	if a.categoria != b.categoria:
		return a.categoria < b.categoria
	return a.nome < b.nome
