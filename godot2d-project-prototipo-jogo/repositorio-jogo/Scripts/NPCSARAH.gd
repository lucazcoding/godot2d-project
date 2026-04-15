extends KinematicBody2D

var playerEntrou = false
var dialogo_ativo = false
var no_atual = 0

# ---------------- HISTÓRIA ----------------
var arvore = [
	{
		"fala": "Ei... voce viu os itens espalhados por ai? Eles podem salvar sua vida.",
		"opcoes": [
			{"texto": "Que itens?", "proximo": 1},
			{"texto": "Nao preciso disso", "proximo": 2}
		]
	},
	{
		"fala": "Existem tres tipos principais. A pocao de vida pode te curar.",
		"opcoes": [
			{"texto": "E os outros?", "proximo": 3},
			{"texto": "Entendi", "proximo": 4}
		]
	},
	{
		"fala": "Tudo bem... mas nao diga que eu nao avisei.",
		"opcoes": []
	},
	{
		"fala": "A granada e poderosa. Ela explode e elimina varios zumbis ao seu redor.",
		"opcoes": [
			{"texto": "E as moedas?", "proximo": 5}
		]
	},
	{
		"fala": "Entao use bem esses itens... voce vai precisar.",
		"opcoes": []
	},
	{
		"fala": "Moedas sao valiosas. Voce pode trocar por itens melhores ou recursos.",
		"opcoes": [
			{"texto": "Obrigado pela dica", "proximo": 6}
		]
	},
	{
		"fala": "Agora va... e tente sobreviver la fora.",
		"opcoes": []
	}
]

# ---------------- READY ----------------
func _ready():
	$Texto.visible = false
	$Yes.visible = false
	$No.visible = false
	$ApertePraFalar.visible = false

# ---------------- INPUT ----------------
func _process(delta):
	if playerEntrou and Input.is_action_just_pressed("ui_accept") and not dialogo_ativo:
		iniciar_dialogo()

# ---------------- INICIAR ----------------
func iniciar_dialogo():
	dialogo_ativo = true
	no_atual = 0
	$ApertePraFalar.visible = false
	$Texto.visible = true
	mostrar_no(no_atual)

# ---------------- MOSTRAR FALA ----------------
func mostrar_no(indice):
	var no = arvore[indice]
	$Texto.text = no.fala

	if no.opcoes.size() == 0:
		$Yes.visible = false
		$No.visible = false
		yield(get_tree().create_timer(3.0), "timeout")
		finalizar_dialogo()
	else:
		$Yes.visible = true
		
		if no.opcoes.size() > 1:
			$No.visible = true
		else:
			$No.visible = false

# ---------------- BOTÃO YES ----------------
func _on_Yes_pressed():
	var opcoes = arvore[no_atual].opcoes
	if opcoes.size() > 0:
		no_atual = opcoes[0].proximo
		mostrar_no(no_atual)

# ---------------- BOTÃO NO ----------------
func _on_No_pressed():
	var opcoes = arvore[no_atual].opcoes
	if opcoes.size() > 1:
		no_atual = opcoes[1].proximo
		mostrar_no(no_atual)

# ---------------- FINALIZAR ----------------
func finalizar_dialogo():
	dialogo_ativo = false
	$Texto.visible = false
	$Yes.visible = false
	$No.visible = false
	
	if playerEntrou:
		$ApertePraFalar.visible = true

# ---------------- AREA ----------------
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		playerEntrou = true
		if not dialogo_ativo:
			$ApertePraFalar.visible = true

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		playerEntrou = false
		$ApertePraFalar.visible = false
