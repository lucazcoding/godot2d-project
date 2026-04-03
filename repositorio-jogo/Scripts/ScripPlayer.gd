extends KinematicBody2D


var speed = 200
var fireball = preload("res://Scenes/Fireball.tscn")

# warning-ignore:unused_argument
func _physics_process(delta):
	movimentar()
	disparar_bolafogo()
	


func _on_Fireball_body_entered(body):
	pass # Replace with function body.

func disparar_bolafogo():
	if Input.is_action_just_pressed("Atirar"):
		var novaboladefogo = fireball.instance()
		
		# adiciona na cena
		get_parent().add_child(novaboladefogo)
		
		# nasce na posição do player
		novaboladefogo.global_position = global_position
		
	   
	

func movimentar():
	var velocity = Vector2()

	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	

	velocity = velocity.normalized() * speed
	move_and_slide(velocity)
