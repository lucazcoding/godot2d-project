extends Node2D

onready var inventory_ui = $UICanvas/InventoryUI

func _ready():

	inventory_ui.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_inventory"):
		inventory_ui.visible = !inventory_ui.visible

		if inventory_ui.visible:
			for slot in inventory_ui.get_node("Panel/Container").get_children():
				if slot.focus_mode == Control.FOCUS_ALL:
					slot.grab_focus()
					break
