extends Control

func _ready():
	$JogarButton.connect("pressed", self, "_on_jogar_button_pressed")
	$SairButton.connect("pressed", self, "_on_sair_button_pressed")

func _on_jogar_button_pressed():
	get_tree().change_scene("res://Scenes/main_game.tscn")

func _on_sair_button_pressed():
	get_tree().quit()
