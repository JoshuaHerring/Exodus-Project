extends Area2D

func _on_body_entered(body):
	checkForPlayer(body)
	checkForProjectile(body)


func checkForPlayer(body):
	if body.is_in_group("player"):
		body.position = body.spawn_point
		body.setDead()

func checkForProjectile(body):
	if body.is_in_group('projectile'):
		body.queue_free()
