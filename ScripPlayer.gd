extends KinematicBody2D


var speed = 200
# warning-ignore:unused_argument
func _physics_process(delta):
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


func _on_Fireball_body_entered(body):
	pass # Replace with function body.
