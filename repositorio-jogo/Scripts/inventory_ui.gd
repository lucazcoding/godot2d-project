extends Control

export(PackedScene) var slot_scene
onready var container = $Panel/Container


onready var btn_ordenar = $Panel/MenuBotoes/BtnOrdenar
onready var btn_todos = $Panel/MenuBotoes/BtnTodos
onready var btn_recurso = $Panel/MenuBotoes/BtnRecurso

func _ready():
	for _i in range(50):
		var novo_slot = slot_scene.instance()
		container.add_child(novo_slot)
		novo_slot.get_node("amount").text = ""
		novo_slot.get_node("item_name").text = ""
		novo_slot.focus_mode = Control.FOCUS_NONE 
		novo_slot.mouse_filter = Control.MOUSE_FILTER_PASS
		

	btn_ordenar.connect("pressed", self, "_on_btn_ordenar_pressed")
	btn_todos.connect("pressed", self, "_on_btn_todos_pressed")
	btn_recurso.connect("pressed", self, "_on_btn_recurso_pressed")
		
	yield(get_tree(), "idle_frame")
	
	var todos_slots = container.get_children()
	var colunas = container.columns 
	
	for i in range(todos_slots.size()):
		var slot_atual = todos_slots[i]
		
		if i % colunas != 0:
			slot_atual.focus_neighbour_left = slot_atual.get_path_to(todos_slots[i - 1])
			
		if (i + 1) % colunas != 0 and (i + 1) < todos_slots.size():
			slot_atual.focus_neighbour_right = slot_atual.get_path_to(todos_slots[i + 1])

		if i >= colunas:
			slot_atual.focus_neighbour_top = slot_atual.get_path_to(todos_slots[i - colunas])
			
		if (i + colunas) < todos_slots.size():
			slot_atual.focus_neighbour_bottom = slot_atual.get_path_to(todos_slots[i + colunas])

func add_visual_item(textura_item: Texture, quantidade: int, nome: String) -> bool:
	for slot in container.get_children():
		if slot.get_node("Sprite").texture == textura_item and slot.get_node("item_name").text == nome:
			var qtd_atual = int(slot.get_node("amount").text)
			slot.get_node("amount").text = str(qtd_atual + quantidade)
			return true
			
	for slot in container.get_children():
		if slot.get_node("Sprite").texture == null:
			slot.get_node("Sprite").texture = textura_item
			slot.get_node("amount").text = str(quantidade)
			slot.get_node("item_name").text = nome
			slot.focus_mode = Control.FOCUS_ALL 
			return true
			
	return false


func atualizar_grade(lista_itens: Array):
	# Esvazia a grade atual
	for slot in container.get_children():
		slot.get_node("Sprite").texture = null
		slot.get_node("amount").text = ""
		slot.get_node("item_name").text = ""
		slot.focus_mode = Control.FOCUS_NONE


	for i in range(lista_itens.size()):
		if i >= 50:
			break
		var item = lista_itens[i]
		var slot = container.get_child(i)
		slot.get_node("Sprite").texture = item["textura"]
		slot.get_node("amount").text = str(item["quantidade"])
		slot.get_node("item_name").text = item["nome"]
		slot.focus_mode = Control.FOCUS_ALL


func _on_btn_ordenar_pressed():
	Inventory.sort_inventory() 
	atualizar_grade(Inventory.items)

func _on_btn_todos_pressed():
	atualizar_grade(Inventory.items)

func _on_btn_recurso_pressed():
	var filtrados = Inventory.get_filtered_items("Recurso")
	atualizar_grade(filtrados)
