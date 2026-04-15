# ItemChao.gd
extends KinematicBody2D

var id = "granada"  # ← muda para cada item: "esmeralda", "granada"
var quantidade = 1
var coletado = false  # ✅ flag anti-duplicação

func _ready():
	add_to_group("ItemChao")
	# Busca os dados no banco e se configura
	var dados = BancoDeItens.itens[id]
	$Sprite.texture = dados.textura

func coletar():
	# Retorna os dados pro player e some do mundo
	var dados = BancoDeItens.itens[id]
	return {
		"id": id,
		"textura": dados.textura,
		"quantidade": quantidade
	}
