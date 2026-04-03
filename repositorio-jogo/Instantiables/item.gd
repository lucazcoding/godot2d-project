extends Area2D

export(String) var nome_item = "Sucata"
export(String) var tipo_item = "Recurso"
export(int) var quantidade = 1

func _ready():
	connect("body_entered", self, "_on_body_entered")
	print("Item pronto no cenário!")

func _on_body_entered(body):
	print("Colisão detectada com: ", body.name)
	
	if Inventory.add_item(nome_item, tipo_item, quantidade, $Sprite.texture):
		print("Item salvo na base global!")
		
		var ui = get_tree().current_scene.get_node("UICanvas/InventoryUI")
		if ui:
			print("Interface encontrada. Enviando textura...")
			ui.add_visual_item($Sprite.texture, quantidade, nome_item)
		else:
			print("ERRO: Caminho UICanvas/InventoryUI divergente na árvore.")
			
		queue_free() # Destrói o item
	else:
		print("ERRO: Inventário lotado.")
