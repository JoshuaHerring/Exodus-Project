extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() and velocity.y <= 800:
		if is_on_wall() and velocity.y >= 0:
			velocity.y = 100
		else:
			velocity.y += 2000 * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	# Handle wall jump logic
	if Input.is_action_just_pressed("jump") and is_on_wall():
		var collsion = get_slide_collision(0)
		var test = collsion.get_normal().x * SPEED * 2
		velocity.x = test
		velocity.y = JUMP_VELOCITY * .7
		
	move_and_slide()
