extends TextureRect

# ================= CONFIG =================
const USAR_HASH := true  # true = hash | false = sort_custom (quicksort)

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
		# QUICKSORT (sort_custom original)
		lista_itens.sort_custom(self, "comparar_itens")
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

# ================= COMPARAÇÃO (quicksort) =================
func comparar_itens(a, b) -> bool:
	if a.categoria != b.categoria:
		return a.categoria < b.categoria
	return a.nome < b.nome
