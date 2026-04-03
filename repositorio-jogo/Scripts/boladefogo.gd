extends KinematicBody2D


var velocidade = 300
var dir = Vector2()


func _ready():
	# direção da fireball até o mouse no momento que ela nasce
	dir = (get_global_mouse_position() - global_position).normalized()

func _physics_process(delta):
	move_and_slide(dir * velocidade)
