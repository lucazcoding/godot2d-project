extends Node

const MAX_ITEMS = 50 
var items = [] 
var order_counter = 0

func add_item(nome_item: String, tipo_item: String, quantidade_item: int, textura: Texture) -> bool:
	if items.size() >= MAX_ITEMS:
		return false
		
	for i in range(items.size()):
		# Exige nome E textura iguais para agrupar
		if items[i]["nome"] == nome_item and items[i]["textura"] == textura:
			items[i]["quantidade"] += quantidade_item
			return true
			
	var novo_item = {
		"nome": nome_item,
		"quantidade": quantidade_item,
		"tipo": tipo_item,
		"textura": textura, 
		"ordem_coleta": order_counter
	}
	
	items.append(novo_item)
	order_counter += 1
	return true

func remove_item(nome_alvo: String):
	for i in range(items.size()):
		if items[i]["nome"] == nome_alvo:
			items.remove(i)
			return

func sort_inventory():
	items = merge_sort(items)

func merge_sort(arr: Array) -> Array:
	if arr.size() <= 1:
		return arr
		
	var mid = arr.size() / 2
	var left = merge_sort(arr.slice(0, mid - 1))
	var right = merge_sort(arr.slice(mid, arr.size() - 1))
	
	return merge(left, right)

func merge(left: Array, right: Array) -> Array:
	var result = []
	var i = 0
	var j = 0
	
	while i < left.size() and j < right.size():
		var item_l = left[i]
		var item_r = right[j]
		
	  
		if item_l["tipo"] < item_r["tipo"]:
			result.append(left[i])
			i += 1
		elif item_l["tipo"] > item_r["tipo"]:
			result.append(right[j])
			j += 1
		else:
			
			if item_l["quantidade"] >= item_r["quantidade"]:
				result.append(left[i])
				i += 1
			else:
				result.append(right[j])
				j += 1
				
	while i < left.size():
		result.append(left[i])
		i += 1
		
	while j < right.size():
		result.append(right[j])
		j += 1
		
	return result

func get_filtered_items(categoria: String) -> Array:
	if categoria == "Todos":
		return items
		
	var filtrados = []
	for item in items:
		if item["tipo"] == categoria:
			filtrados.append(item)
			
	return filtrados
