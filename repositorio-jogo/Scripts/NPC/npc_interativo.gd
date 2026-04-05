extends Node2D
class_name NPCInterativo

signal interaction_requested

export(String) var npc_id = "npc_survivor_01"
export(String) var dialogue_id = "survivor_mara"

onready var interaction_area = $InteractionArea
onready var prompt_label = $PromptLabel

var player_in_range = false
var interaction_locked = false
var claimed_reward_nodes = {}

func _ready():
	add_to_group("interactable_npcs")
	prompt_label.visible = false
	prompt_label.text = "Pressione E"

	interaction_area.connect("body_entered", self, "_on_body_entered")
	interaction_area.connect("body_exited", self, "_on_body_exited")

func _process(_delta):
	if interaction_locked:
		return

	if player_in_range and Input.is_action_just_pressed("interact"):
		emit_signal("interaction_requested", self)

func set_interaction_locked(value):
	interaction_locked = value

func can_claim_reward(node_id):
	return not claimed_reward_nodes.get(node_id, false)

func mark_reward_claimed(node_id):
	claimed_reward_nodes[node_id] = true

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		prompt_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		prompt_label.visible = false
