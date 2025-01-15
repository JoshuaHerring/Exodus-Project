extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const TERMINAL_VELOCITY = 600
const GRAVITY = 2000
const WALL_SLIDE_VELOCITY = 200
const TEST_BULLET = preload("res://scenes/test_bullet.tscn")

# DIVIDE THE LOGIC UP INTO FUNCTIONS AND ABSTRACT
func _physics_process(delta):
	movement(delta)
	shoot()
	move_and_slide()


func shoot():
	if Input.is_action_just_pressed("fire"):
		print('bang')
		var bulleteInstance = TEST_BULLET.instantiate()
		bulleteInstance.position = position
		get_parent().add_child(bulleteInstance)

func gravity(delta):
	# Handle gravity
	if not is_on_floor() and velocity.y <= TERMINAL_VELOCITY:
		# Handle wall slide
		if is_on_wall() and velocity.y >= 0:
			velocity.y = move_toward(velocity.y, WALL_SLIDE_VELOCITY, SPEED)
		else:
			velocity.y += GRAVITY * delta

func jump():
	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func wallJump():
	# Handle wall jump logic
	if Input.is_action_just_pressed("jump") and is_on_wall():
		var collsion = get_slide_collision(0)
		velocity.x = collsion.get_normal().x * SPEED * 2
		velocity.y = JUMP_VELOCITY * .8
	

func move():
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED / 2)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func terminalVelocity():
	# Prevent the player from exceding terminal velocity
	if velocity.y > TERMINAL_VELOCITY:
		velocity.y = TERMINAL_VELOCITY

func movement(delta):
	gravity(delta)
	jump()
	move()
	wallJump()
	terminalVelocity()
