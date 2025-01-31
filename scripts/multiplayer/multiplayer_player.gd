extends CharacterBody2D

const BULLET = preload("res://scenes/bullet.tscn")
@onready var gameManager = $"../.."
@onready var hand = $Hand



const SPEED : int = 300
const JUMP_VELOCITY : int = -500
const TERMINAL_VELOCITY : int = 600
const GRAVITY : int = 2000
const WALL_SLIDE_VELOCITY : int = 150
const HAND_DISTANCE : float = 20
const MAX_HEALTH : int = 100
const RESPAWN_TIMER_MAX : float = 1

var direction : int = 1
var do_jump : bool = false
var do_shoot : bool = false
var _is_on_floor : bool = true
var health : int = MAX_HEALTH
var alive : bool = true
var damage : int = 110
var bullet_speed : int = 500
var bullet_bounces : int = 2
# The size of the bullet needs to modify how far away the bullet spawns otherwise larger bullets hit the player upon shooting
var bullet_size : float = 1
var respawn_timer : float = RESPAWN_TIMER_MAX
# The direction to shoot the bullet based off of the aim function
var bullet_velocity : Vector2

@export var player_id : int = 1:
	set(id):
		player_id = id
		$InputSyncronizer.set_multiplayer_authority(id)
	
@export var cursor_position : Vector2


# DIVIDE THE LOGIC UP INTO FUNCTIONS AND ABSTRACT
func _physics_process(delta):
	cursor_position = get_global_mouse_position()
	if !alive:
		respawn_timer -= delta
		if respawn_timer < 0:
			setAlive()
	else:
		if multiplayer.is_server():
			movement(delta)
			#aim()
			move_and_slide()

func shoot(bullet_velocity, bullet_start):
	if do_shoot:
		do_shoot = false
		var bulleteInstance = BULLET.instantiate()
		bulleteInstance.position = bullet_start
		bulleteInstance.linear_velocity = bullet_velocity
		get_parent().get_parent().get_node("Bullets").add_child(bulleteInstance, true)
		
		bulleteInstance.modifyBulletVariables(damage, bullet_bounces, bullet_size)

func gravity(delta):
	# Handle gravity
	if not is_on_floor() and velocity.y <= TERMINAL_VELOCITY:
		# Handle wall slide
		if is_on_wall() and velocity.y >= 0:
			velocity.y = move_toward(velocity.y, WALL_SLIDE_VELOCITY, SPEED)
		else:
			velocity.y += GRAVITY * delta

func jump():
	# Handle jump. do_jump is handled by an rpc from the syncronizer
	if do_jump and is_on_floor():
		do_jump = false
		velocity.y = JUMP_VELOCITY

func wallJump():
	# Handle wall jump logic
	if do_jump and is_on_wall():
		do_jump = false
		var collsion = get_slide_collision(0)
		velocity.x = collsion.get_normal().x * SPEED * 2
		velocity.y = JUMP_VELOCITY * .8
	

func move():
	# Get the input direction from the snycronizer and handle the movement/deceleration.
	direction = $InputSyncronizer.input_direction
#	Update the syncronized is on floor variable with the current is on floor status
	_is_on_floor = is_on_floor()
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED / 2)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func terminalVelocity():
	# Prevent the player from exceding terminal velocity
	if velocity.y > TERMINAL_VELOCITY:
		velocity.y = TERMINAL_VELOCITY

func aim(aim_position):
	var player_position = global_position
	# Calculate the direction vector from the player to the cursor
	var direction_vector = (aim_position - player_position).normalized()
	
	# Use the hand to aim
	hand.global_position = player_position + direction_vector * HAND_DISTANCE
	
	# Calculate velocity
	bullet_velocity = direction_vector * bullet_speed
	# Shoot the bullet with the above velocity
	shoot(bullet_velocity, hand.global_position)

func minusHealth(healthChange):
	health -= healthChange
	print(health)
	if health < 0 && alive:
		setDead()

func setDead():
	alive = false
	if multiplayer.is_server():
		rpc_switch_level.rpc()
			
@rpc("authority", "call_local")
func rpc_switch_level():
	gameManager.switch_level()


func setAlive():
	alive = true
	health = MAX_HEALTH
	respawn_timer = RESPAWN_TIMER_MAX
	
	

func movement(delta):
	gravity(delta)
	jump()
	move()
	wallJump()
	terminalVelocity()
