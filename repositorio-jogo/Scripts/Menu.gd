extends TextureRect




func _on_BtnJogar_pressed():
	get_tree().change_scene("res://Scenes/Fase1.tscn")


func _on_BtnSair_pressed():
	get_tree().quit()
