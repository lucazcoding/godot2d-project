extends KinematicBody2D

var playerEntrou = false
var dialogo_ativo = false
var no_atual = 0

var arvore = [
	# no 0 - inicio
	{
		"fala": "Ugh... voce... ainda esta vivo? Eu quase nao consegui. Esses monstros estao por toda parte.",
		"opcoes": [
			{"texto": "O que aconteceu com voce?", "proximo": 1},
			{"texto": "Nao tenho tempo pra isso", "proximo": 2}
		]
	},

	# no 1 - conta o que aconteceu
	{
		"fala": "Eu fazia parte de um grupo de sobreviventes. Fomos emboscados... so eu escapei. Aprendi uma coisa importante sobre essas criaturas.",
		"opcoes": [
			{"texto": "O que voce aprendeu?", "proximo": 3},
			{"texto": "Sinto muito pelo seu grupo", "proximo": 4}
		]
	},

	# no 2 - despedida
	{
		"fala": "Tudo bem... vai em frente. Mas cuidado... eles sao mais rapidos do que parecem.",
		"opcoes": []
	},

	# no 3 - dica sobre inimigos
	{
		"fala": "Eles ficam mais agressivos quando voce chega perto demais. Mantenha distancia e ataque de longe... eh a unica forma segura.",
		"opcoes": [
			{"texto": "Mais alguma dica?", "proximo": 5},
			{"texto": "Obrigado pela ajuda", "proximo": 6}
		]
	},

	# no 4 - empatia
	{
		"fala": "Obrigado... eramos cinco. Agora so eu. Mas nao posso desistir... e voce tambem nao pode.",
		"opcoes": [
			{"texto": "Vou continuar lutando", "proximo": 5},
			{"texto": "Boa sorte pra nos dois", "proximo": 6}
		]
	},

	# no 5 - dica extra
	{
		"fala": "Vi um deposito ao norte... pode ter suprimentos la. Mas tambem vi sombras se movendo. Va preparado.",
		"opcoes": [
			{"texto": "Vou verificar", "proximo": 6}
		]
	},

	# no 6 - final
	{
		"fala": "Boa sorte la fora... e se encontrar outros sobreviventes... diga que ainda ha esperanca.",
		"opcoes": []
	}
]

# -----------------------------------------------
# READY - tudo comeca escondido
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
		$Yes.visible = false
		$No.visible = false
		yield(get_tree().create_timer(5.0), "timeout")
		finalizar_dialogo()
	else:
		$Yes.visible = true
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
