extends Sprite





func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		get_tree().change_scene("res://Scenes/Fase2.tscn")
