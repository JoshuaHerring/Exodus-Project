extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	checkForPlayer(body)
	checkForProjectile(body)


func checkForPlayer(body):
	if body.is_in_group("player"):
		body.position = Vector2(0, 0)
		body.setDead()

func checkForProjectile(body):
	if body.is_in_group('projectile'):
		body.queue_free()
