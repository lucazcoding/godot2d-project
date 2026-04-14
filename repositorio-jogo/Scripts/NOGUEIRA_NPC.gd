extends KinematicBody2D

var playerEntrou = false
var dialogo_ativo = false
var no_atual = 0

var arvore = [
	# no 0 - inicio
	{
		"fala": "Ei... voce ai... Eu sou apenas um fazendeiro. Minha filha... ela desapareceu depois que esses zumbis apareceram...",
		"opcoes": [
			{"texto": "O que aconteceu?", "proximo": 1},
			{"texto": "Nao posso ajudar", "proximo": 2}
		]
	},

	# nó 1 - explicação
	{
		"fala": "Essas criaturas tomaram conta das terras. Eu preciso eliminar pelo menos 10 zumbis para conseguir abrir o portao da fazenda... talvez ela esteja la dentro.",
		"opcoes": [
			{"texto": "Eu ajudo voce", "proximo": 3},
			{"texto": "Isso e perigoso demais", "proximo": 2}
		]
	},

	# nó 2 - despedida
	{
		"fala": "Entendo... ninguem quer se arriscar hoje em dia. Mas se mudar de ideia, estarei aqui.",
		"opcoes": []
	},

	# nó 3 - missão aceita
	{
		"fala": "Obrigado... de verdade. Derrote 10 zumbis e o portao sera liberado. Eu... eu so quero ver minha filha novamente.",
		"opcoes": [
			{"texto": "Vou acabar com eles", "proximo": 4}
		]
	},

	# nó 4 - final
	{
		"fala": "Por favor, tenha cuidado la fora... esses monstros nao eram assim antes...",
		"opcoes": []
	}
]

# -----------------------------------------------
# READY - tudo começa escondido
# -----------------------------------------------
func _ready():
	$Yes.visible = false
	$No.visible = false
	$Texto.visible = false

func _process(delta):
	if playerEntrou and Input.is_action_just_pressed("ui_accept") and not dialogo_ativo:
		iniciar_dialogo()

func iniciar_dialogo():
	dialogo_ativo = true
	no_atual = 0
	$ApertePraFalar.visible = false
	$Texto.visible = true
	mostrar_no(no_atual)

func mostrar_no(indice):
	var no = arvore[indice]
	$Texto.text = no.fala

	if no.opcoes.size() == 0:
		# Fim do diálogo, esconde botões
		$Yes.visible = false
		$No.visible = false
		yield(get_tree().create_timer(5.0), "timeout")
		finalizar_dialogo()
	else:
		# Mostra Yes sempre que tiver opção
		$Yes.visible = true

		# Só mostra No se tiver segunda opção
		if no.opcoes.size() > 1:
			$No.visible = true
		else:
			$No.visible = false

func _on_Yes_pressed():
	var opcoes = arvore[no_atual].opcoes
	if opcoes.size() > 0:
		no_atual = opcoes[0].proximo
		mostrar_no(no_atual)

func _on_No_pressed():
	var opcoes = arvore[no_atual].opcoes
	if opcoes.size() > 1:
		no_atual = opcoes[1].proximo
		mostrar_no(no_atual)

func finalizar_dialogo():
	dialogo_ativo = false
	$Texto.visible = false
	$Yes.visible = false
	$No.visible = false
	if playerEntrou:
		$ApertePraFalar.visible = true

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		playerEntrou = true
		if not dialogo_ativo:
			$ApertePraFalar.visible = true

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		playerEntrou = false
		$ApertePraFalar.visible = false
		$Texto.visible = false
		$Yes.visible = false
		$No.visible = false
		dialogo_ativo = false
