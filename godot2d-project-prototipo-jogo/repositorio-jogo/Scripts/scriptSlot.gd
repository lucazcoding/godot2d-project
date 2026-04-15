extends Control

const MAX_QUANTIDADE = 64

var previa
var arrastando = false
var drop_realizado = false
var item_backup = {}
var id_atual = ""  # ← id do item que está neste slot

func _ready():
	add_to_group("Slots")

# -----------------------------------------------
# PEGAR ITEM
# -----------------------------------------------
func get_drag_data(position):
	if $Item_Sprite.texture == null:
		return null

	arrastando = true
	drop_realizado = false

	item_backup = {
		"id": id_atual,
		"textura": $Item_Sprite.texture,
		"quantidade": int($Amount.text) if $Amount.text != "" else 0
	}

	previa = self.duplicate(true)
	previa.get_node("Background").hide()
	previa.get_node("Amount").hide()
	previa.get_node("Item_Sprite").rect_position = -previa.rect_size / 2

	$Item_Sprite.texture = null
	$Amount.text = ""
	id_atual = ""

	set_drag_preview(previa)

	return {
		"id": item_backup.id,
		"textura": item_backup.textura,
		"quantidade": item_backup.quantidade,
		"origem": self
	}

# -----------------------------------------------
# PERMISSÃO DE DROP
# -----------------------------------------------
func can_drop_data(position, dados):
	return is_in_group("Slots")

# -----------------------------------------------
# SOLTAR ITEM
# -----------------------------------------------
func drop_data(position, dados):
	var origem = dados.get("origem")
	var id_arrastado = dados.id
	var textura_arrastada = dados.textura
	var qtd_arrastada = dados.quantidade

	# CASO 1: Slot vazio
	if $Item_Sprite.texture == null:
		id_atual = id_arrastado
		$Item_Sprite.texture = textura_arrastada
		$Amount.text = str(qtd_arrastada)
		origem.confirmar_drop()

	# CASO 2: Mesmo item → empilha
	elif id_atual == id_arrastado:
		var qtd_destino = int($Amount.text)
		var total = qtd_destino + qtd_arrastada

		if total <= MAX_QUANTIDADE:
			$Amount.text = str(total)
			origem.confirmar_drop()
		else:
			var sobra = total - MAX_QUANTIDADE
			$Amount.text = str(MAX_QUANTIDADE)
			origem.restaurar_parcial(id_arrastado, textura_arrastada, sobra)
			origem.confirmar_drop()

	# CASO 3: Item diferente → troca
	else:
		var id_destino = id_atual
		var textura_destino = $Item_Sprite.texture
		var qtd_destino = int($Amount.text)

		id_atual = id_arrastado
		$Item_Sprite.texture = textura_arrastada
		$Amount.text = str(qtd_arrastada)

		origem.restaurar_parcial(id_destino, textura_destino, qtd_destino)
		origem.confirmar_drop()

# -----------------------------------------------
# CONFIRMAR DROP
# -----------------------------------------------
func confirmar_drop():
	drop_realizado = true
	item_backup = {}
	arrastando = false

# -----------------------------------------------
# RESTAURAR PARCIAL
# -----------------------------------------------
func restaurar_parcial(id, textura, quantidade):
	id_atual = id
	$Item_Sprite.texture = textura
	$Amount.text = str(quantidade)

# -----------------------------------------------
# PROCESS
# -----------------------------------------------
func _process(delta):
	if arrastando and Input.is_action_just_released("mouse_left"):
		arrastando = false
		if not drop_realizado:
			id_atual = item_backup.id
			$Item_Sprite.texture = item_backup.textura
			$Amount.text = str(item_backup.quantidade)

# -----------------------------------------------
# ADICIONAR ITEM (chamado pela coleta)
# -----------------------------------------------
func tentar_adicionar_item(id, textura, quantidade):
	# Slot vazio
	if $Item_Sprite.texture == null:
		id_atual = id
		$Item_Sprite.texture = textura
		$Amount.text = str(quantidade)
		return 0

	# Mesmo item, empilha
	if id_atual == id:
		var atual = int($Amount.text)
		var total = atual + quantidade
		if total <= MAX_QUANTIDADE:
			$Amount.text = str(total)
			return 0
		else:
			$Amount.text = str(MAX_QUANTIDADE)
			return total - MAX_QUANTIDADE

	# Item diferente, não empilha
	return quantidade
