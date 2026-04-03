extends KinematicBody2D

var velocidade = 300

func _process(delta):

	var inventory_ui = get_tree().current_scene.get_node_or_null("UICanvas/InventoryUI")
	

	if inventory_ui and inventory_ui.visible:
		return
		
	var direcao = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"): 
		direcao.x += 1
	if Input.is_action_pressed("ui_left"): 
		direcao.x -= 1
	if Input.is_action_pressed("ui_down"): 
		direcao.y += 1
	if Input.is_action_pressed("ui_up"): 
		direcao.y -= 1
		
	position += direcao.normalized() * velocidade * delta
