extends Control




func _on_ButtonRessurgir_pressed():
	get_tree().change_scene("res://Scenes/Menu.tscn")


func _on_ButtonPaz_pressed():
	get_tree().quit()
