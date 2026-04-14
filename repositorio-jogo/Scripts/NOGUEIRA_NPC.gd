extends KinematicBody2D

var playerEntrou = false
var dialogo_ativo = false
var no_atual = 0

var arvore = [
	# nó 0 - início
	{
		"fala": "Ei... você aí... eu preciso de ajuda. Minha filha desapareceu depois que esses zumbis apareceram na fazenda...",
		"opcoes": [
			{"texto": "O que aconteceu?", "proximo": 1},
			{"texto": "Não posso ajudar", "proximo": 2}
		]
	},
	# nó 1 - explica missão
	{
		"fala": "Essas criaturas tomaram conta do lugar... O portão principal está travado. Acho que só eliminando alguns deles conseguimos liberar a passagem.",
		"opcoes": [
			{"texto": "Quantos preciso derrotar?", "proximo": 3},
			{"texto": "Isso é perigoso demais", "proximo": 2}
		]
	},
	# nó 2 - despedida
	{
		"fala": "Entendo... se mudar de ideia, estarei aqui. Eu não posso desistir dela...",
		"opcoes": []
	},
	# nó 3 - missão definida
	{
		"fala": "Mate 10 zumbis... isso deve enfraquecer o controle deles sobre o portão. Por favor... traga minha filha de volta...",
		"opcoes": [
			{"texto": "Vou ajudar", "proximo": 2}
		]
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
		yield(get_tree().create_timer(2.0), "timeout")
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
		
		# Esconde tudo
		$ApertePraFalar.visible = false
		$Texto.visible = false
		$Yes.visible = false
		$No.visible = false
		
		# Reseta completamente o diálogo
		dialogo_ativo = false
		no_atual = 0
