extends Node2D

onready var dialogue_ui = $DialogueUI

var active_npc = null

func _ready():
	dialogue_ui.connect("dialogue_closed", self, "_on_dialogue_closed")

	for npc in get_tree().get_nodes_in_group("interactable_npcs"):
		if npc is NPCInterativo:
			npc.connect("interaction_requested", self, "_on_npc_interaction_requested")

func _on_npc_interaction_requested(npc):
	if active_npc != null:
		return

	active_npc = npc
	npc.set_interaction_locked(true)
	dialogue_ui.open_for_npc(npc)

func _on_dialogue_closed(npc):
	if npc != null:
		npc.set_interaction_locked(false)

	active_npc = null
