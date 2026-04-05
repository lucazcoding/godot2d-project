extends CanvasLayer
class_name DialogueUI

signal dialogue_closed(npc)

const END_NODE = "END"

onready var speaker_label = $PanelContainer/MarginContainer/VBoxContainer/SpeakerLabel
onready var text_label = $PanelContainer/MarginContainer/VBoxContainer/TextLabel
onready var choices_container = $PanelContainer/MarginContainer/VBoxContainer/ChoicesContainer

var current_npc = null
var current_dialogue = {}
var current_node_id = ""

func _ready():
	visible = false

func open_for_npc(npc):
	current_npc = npc
	current_dialogue = DialogueData.get_dialogue(npc.dialogue_id)

	if current_dialogue.empty():
		push_warning("Diálogo '%s' não encontrado." % npc.dialogue_id)
		return

	visible = true
	_show_node("start")

func close_dialogue():
	visible = false
	_clear_choices()

	var npc = current_npc
	current_npc = null
	current_dialogue = {}
	current_node_id = ""

	emit_signal("dialogue_closed", npc)

func _show_node(node_id):
	if node_id == END_NODE:
		close_dialogue()
		return

	if not current_dialogue.has(node_id):
		push_warning("Nó de diálogo '%s' não encontrado." % node_id)
		close_dialogue()
		return

	current_node_id = node_id

	var node = current_dialogue[node_id]

	speaker_label.text = str(node.get("speaker", "???"))
	text_label.text = str(node.get("text", ""))

	_apply_node_reward(node_id, node)
	_rebuild_choices(node)

func _rebuild_choices(node):
	_clear_choices()

	var options = node.get("options", [])

	if options.empty():
		var close_button = Button.new()
		close_button.text = "Fechar"
		close_button.connect("pressed", self, "close_dialogue")
		choices_container.add_child(close_button)
		return

	for option in options:
		var button = Button.new()
		button.text = str(option.get("text", "Continuar"))
		button.connect("pressed", self, "_on_option_pressed", [option])
		choices_container.add_child(button)

func _on_option_pressed(option):
	var next_id = str(option.get("next", END_NODE))
	_show_node(next_id)

func _apply_node_reward(node_id, node):
	if not node.has("reward"):
		return

	var reward = node["reward"]
	var reward_once = bool(node.get("reward_once", false))

	if reward_once:
		if current_npc == null:
			return
		if not current_npc.can_claim_reward(node_id):
			return
		_apply_reward_to_player(reward)
		current_npc.mark_reward_claimed(node_id)
	else:
		_apply_reward_to_player(reward)

func _apply_reward_to_player(reward):
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return

	var player = players[0]

	if reward.has("ammo") and player.has_method("add_ammo"):
		player.add_ammo(int(reward["ammo"]))

	if reward.has("heal") and player.has_method("heal"):
		player.heal(int(reward["heal"]))

	if reward.has("gold") and player.has_method("add_gold"):
		player.add_gold(int(reward["gold"]))

func _clear_choices():
	for child in choices_container.get_children():
		child.queue_free()
