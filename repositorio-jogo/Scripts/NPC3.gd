extends KinematicBody2D

var playerEntrou = false
var dialogo_ativo = false
var no_atual = 0

var arvore = [
	# no 0 - inicio
	{
		"fala": "Ah... um viajante. Faz tempo que nao vejo alguem por aqui. Diga me... voce busca poder ou conhecimento?",
		"opcoes": [
			{"texto": "Busco poder", "proximo": 1},
			{"texto": "Busco conhecimento", "proximo": 2}
		]
	},
	# no 1 - caminho do poder
	{
		"fala": "O poder tem um preco. Muitos vieram antes de voce... poucos sobreviveram para contar a historia.",
		"opcoes": [
			{"texto": "Nao tenho medo", "proximo": 3},
			{"texto": "Talvez eu deva reconsiderar", "proximo": 4}
		]
	},
	# no 2 - caminho do conhecimento
	{
		"fala": "Sabedoria eh uma lamina de dois gumes. Quanto mais voce sabe... mais dificil eh ignorar a verdade.",
		"opcoes": [
			{"texto": "Quero aprender", "proximo": 5},
			{"texto": "Prefiro nao saber", "proximo": 4}
		]
	},
	# no 3 - desafio
	{
		"fala": "Entao prove sua forca. Derrote 5 guardioes das sombras e volte ate mim. So assim reconhecerei seu valor.",
		"opcoes": []
	},
	# no 4 - desistiu
	{
		"fala": "Uma escolha sabia... ou covarde. De qualquer forma, o mundo continuara o mesmo sem voce.",
		"opcoes": []
	},
	# no 5 - recompensa conhecimento
	{
		"fala": "Muito bem... entao escute com atencao: nem todos os inimigos sao aquilo que parecem ser. Observe antes de atacar.",
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
