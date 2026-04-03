extends Area2D

export var velocidade = 400
export var dano = 10

var direcao = Vector2.RIGHT

func _ready():
	connect("body_entered", self, "_ao_colidir")

func _physics_process(delta):
	position += direcao * velocidade * delta

func _ao_colidir(corpo):
	if corpo.has_method("receber_dano"):
		corpo.receber_dano(dano)
	queue_free()
