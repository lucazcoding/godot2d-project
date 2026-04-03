extends Area2D

export var speed = 400
export var damage = 10

var direction = Vector2.RIGHT

func _process(delta):
	position += direction * speed * delta

func _on_Fireball_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)

	queue_free()
