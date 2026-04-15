extends KinematicBody2D

var speed = 400
var direcao = Vector2.ZERO
onready var raycast = get_node("RayCast2D")

func _ready():
	rotation = direcao.angle()

func _physics_process(delta):
	var info = move_and_collide(direcao * speed * delta)
	if info:
		if "Enemy" in info.collider.name:
			info.collider.tomar_dano(2)
			queue_free()
	
	if raycast.is_colliding():
		var col = raycast.get_collider()
		if col is TileMap and col.name == "TileMapObstaculos":
			queue_free()
	
	
