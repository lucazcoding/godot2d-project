extends TextureRect

# ================= INVENTÁRIO =================
func _ready():
	visible = false

func _process(delta):
	if Input.is_action_just_pressed("abrir_inventario"):
		visible = !visible
		if visible:
			ordenar_slots()

# ================= ORDENAÇÃO =================
func ordenar_slots():
	var slots = get_tree().get_nodes_in_group("Slots")
	var lista_itens = []

	# 1. Lê e limpa cada slot ocupado
	for slot in slots:
		if slot.id_atual != "":
			var dados = BancoDeItens.itens[slot.id_atual]
			lista_itens.append({
				"id":        slot.id_atual,
				"categoria": dados.categoria,
				"nome":      dados.nome,
				"textura":   slot.get_node("Item_Sprite").texture,
				"quantidade": int(slot.get_node("Amount").text) if slot.get_node("Amount").text != "" else 1
			})
			# Limpa imediatamente para não duplicar
			slot.id_atual = ""
			slot.get_node("Item_Sprite").texture = null
			slot.get_node("Amount").text = ""
			slot.arrastando = false

	# 2. Ordena: categoria → nome
	#QUICKSORT
	lista_itens.sort_custom(self, "comparar_itens")

	# 3. Redistribui nos slots
	for i in range(lista_itens.size()):
		var item = lista_itens[i]
		var slot = slots[i]
		slot.id_atual = item.id
		slot.get_node("Item_Sprite").texture = item.textura
		# ✅ Só exibe número se quantidade for maior que 1
		slot.get_node("Amount").text = str(item.quantidade) if item.quantidade > 1 else ""

# ================= COMPARAÇÃO =================
func comparar_itens(a, b):
	if a.categoria != b.categoria:
		return a.categoria < b.categoria
	return a.nome < b.nome
