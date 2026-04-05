extends KinematicBody2D

export var speed = 200

var ammo = 0
var current_health = 100
var max_health = 100

func _ready():
	add_to_group("player")

func _physics_process(_delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	direction = direction.normalized()
	move_and_slide(direction * speed)

func add_ammo(value):
	ammo += value
	print("Munição:", ammo)

func heal(value):
	current_health = min(max_health, current_health + value)
	print("Vida:", current_health)

func add_gold(value):
	print("Ouro recebido:", value)
