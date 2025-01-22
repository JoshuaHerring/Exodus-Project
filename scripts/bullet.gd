extends RigidBody2D

@onready var collision_shape_2d = $CollisionShape2D
@onready var mesh_instance_2d = $MeshInstance2D
@onready var collision_detector = $collisionDetector/CollisionShape2D

var lifespan = 5
var bounces = 1

func _ready():
	pass

func _process(delta):
	
	if(lifespan < 0):
		queue_free()
	lifespan -= delta

# call this to modify the values of a bullet
# Normally called when bullets are shot
func modifyBulletVariables(addBounces = 0, addSize = 0):
	bounces += addBounces
	
	collision_shape_2d.scale += Vector2(addSize, addSize)
	mesh_instance_2d.scale += Vector2(addSize, addSize)
	collision_detector.scale += Vector2(addSize, addSize)

func _on_collision_detector_area_entered(area):
	if bounces > 0:
		bounces -= 1
	else:
		queue_free()

func _on_collision_detector_body_entered(body):
	if bounces > 0:
		bounces -= 1
	else:
		queue_free()
