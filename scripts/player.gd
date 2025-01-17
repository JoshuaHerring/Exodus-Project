extends CharacterBody2D

const TEST_BULLET = preload("res://scenes/test_bullet.tscn")
@onready var hand = $Hand


const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const TERMINAL_VELOCITY = 600
const GRAVITY = 2000
const WALL_SLIDE_VELOCITY = 150
const HAND_DISTANCE = 20

var bullet_speed = 500

# DIVIDE THE LOGIC UP INTO FUNCTIONS AND ABSTRACT
func _physics_process(delta):
	movement(delta)
	#shoot()
	aim()
	move_and_slide()

func shoot(bullet_velocity, bullet_start):
	if Input.is_action_just_pressed("fire"):
		print('bang')
		var bulleteInstance = TEST_BULLET.instantiate()
		bulleteInstance.position = bullet_start
		bulleteInstance.linear_velocity = bullet_velocity
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

func aim():
	var cursor_position = get_global_mouse_position()
	var player_position = global_position
	# Calculate the direction vector from the player to the cursor
	var direction_vector = (cursor_position - player_position).normalized()
	
	# Use the hand to aim
	hand.global_position = player_position + direction_vector * HAND_DISTANCE
	
	# Optionally, rotate the hand to face the cursor var direction_vector = (cursor_position - player_position).normalized() hand.rotation = direction_vector.angle()
	
	# Calculate velocity
	var bullet_velocity = direction_vector * bullet_speed
	# Shoot the bullet with the above velocity
	shoot(bullet_velocity, hand.global_position)

	

func movement(delta):
	gravity(delta)
	jump()
	move()
	wallJump()
	terminalVelocity()
