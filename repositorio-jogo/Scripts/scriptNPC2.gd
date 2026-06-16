extends KinematicBody2D

var playerEntrou = false
var dialogo_ativo = false
var no_atual = 0
var fonte = null

var arvore = [
	# no 0 - aviso inicial
	{
		"fala": "Guerreiro, antes de seguir preciso avisa-lo. A saida deste lugar esta selada. Apenas aqueles que derrotarem todos os inimigos poderao avancar.",
		"opcoes": [
			{"texto": "O que preciso fazer?", "proximo": 1},
			{"texto": "Vou encontrar meu proprio caminho", "proximo": 2}
		]
	},

	# no 1 - missao
	{
		"fala": "Adiante voce enfrentara diversos monstros. Derrote todos eles e o caminho sera liberado. Somente entao podera continuar sua jornada.",
		"opcoes": [
			{"texto": "Estou pronto para a batalha", "proximo": 3},
			{"texto": "Preciso me preparar melhor", "proximo": 2}
		]
	},

	# no 2 - despedida
	{
		"fala": "Entao retorne quando estiver pronto. A saida permanecera fechada ate que todos os inimigos sejam derrotados.",
		"opcoes": []
	},

	# no 3 - aceitou a missao
	{
		"fala": "Va, guerreiro. Enfrente os monstros que habitam este lugar, derrote cada um deles e prove seu valor. Quando o ultimo cair, a saida sera aberta.",
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
	fonte = $Texto.get_font("font")
	
	if fonte:
		fonte.size = 140
	else:
		print("Fonte não encontrada")

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
