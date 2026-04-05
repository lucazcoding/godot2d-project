# BancoDeItens.gd
extends Node

var itens = {
	"pocao_vida": {
		"id": "pocao_vida",
		"nome": "Poção de Vida",
		"categoria": "Cura",
		"quantidade_max": 2,
		"textura": preload("res://Sprites/pocao_vida.png")
	},
	"esmeralda": {
		"id": "esmeralda",
		"nome": "Esmeralda",
		"categoria": "Moeda",
		"quantidade_max": 64,
		"textura": preload("res://Sprites/esmeralda_modea-removebg-preview.png")
	},
	"granada": {
		"id": "granada",
		"nome": "Granada",
		"categoria": "Recurso",
		"quantidade_max": 64,
		"textura": preload("res://Sprites/grenade.png")
	}
}
