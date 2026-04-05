extends KinematicBody2D

var playerEntrou = false
var dialogo_ativo = false
var no_atual = 0

var arvore = [
	# no 0 - inicio
	{
		"fala": "Sou o guardiao deste corredor. Antes de seguir preciso te avisar: adiante criaturas espreitam na escuridao.",
		"opcoes": [
			{"texto": "Que tipo de criaturas?", "proximo": 1},
			{"texto": "Nao me importo vou seguir", "proximo": 2}
		]
	},
	# no 1 - explicacao da missao
	{
		"fala": "Monstros sedentos por batalha. Para provar seu valor e avancar em sua jornada voce deve derrotar 10 deles.",
		"opcoes": [
			{"texto": "Estou pronto", "proximo": 3},
			{"texto": "Talvez eu deva me preparar mais", "proximo": 2}
		]
	},
	# no 2 - despedida
	{
		"fala": "Entao volte quando estiver pronto. Nem toda coragem nasce da pressa.",
		"opcoes": []
	},
	# no 3 - aceitou o desafio
	{
		"fala": "Va guerreiro. Lembre se nao sao os monstros que definem sua forca mas aquilo que voce escolhe se tornar ao enfrenta los.",
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
