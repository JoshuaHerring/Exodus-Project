extends CharacterBody2D

const BULLET = preload("res://scenes/bullet.tscn")
@onready var gameManager = $"../.."
@onready var hand = $Hand
@onready var texture_progress_bar = $TextureProgressBar
@onready var bullet_audio = $BulletAudio



const TERMINAL_VELOCITY : int = 600
const WALL_SLIDE_VELOCITY : int = 150
const HAND_DISTANCE : float = 20
const RESPAWN_TIMER_MAX : float = 1

var jump_velocity : int = -500
var gravity : int = 2000
var max_health : int = 100
var max_bullets : int = 10
var speed : int = 300
var damage : int = 10
var bullet_speed : int = 500
var bullet_bounces : int = 0
# The size of the bullet needs to modify how far away the bullet spawns otherwise larger bullets hit the player upon shooting
var bullet_size : float = 1
# Var's above this are stats that can be affect by cards

var health : int = max_health
var bullets : int = max_bullets
var reload_speed : float = 1
var relaod_progress : float = reload_speed
var reloading : bool = false
var fire_cooldown : float = .5
var fire_cooldown_progress : float = fire_cooldown
var fire_coolingdown : bool = false
var direction : int = 1
var alive : bool = true
var do_jump : bool = false
var do_shoot : bool = false
var _is_on_floor : bool = true
var respawn_timer : float = RESPAWN_TIMER_MAX
# The direction to shoot the bullet based off of the aim function
var bullet_velocity : Vector2

@export var player_id : int = 1:
	set(id):
		player_id = id
		$InputSyncronizer.set_multiplayer_authority(id)
	
@export var cursor_position : Vector2

func _ready():
	texture_progress_bar.value = health
	texture_progress_bar.max_value = max_health
	$NameLabel.text = name.substr(0, 3)
	

func _physics_process(delta):
	cursor_position = get_global_mouse_position()
	if !alive:
		respawn_timer -= delta
		if respawn_timer < 0:
			setAlive()
	else:
		if multiplayer.is_server():
			movement(delta)
			move_and_slide()
			if fire_coolingdown:
				fire_cooldown_progress -= delta
				if fire_cooldown_progress <= 0:
					fire_coolingdown = false
					fire_cooldown_progress = fire_cooldown
				
			if reloading:
				relaod_progress -= delta
				if relaod_progress <= 0:
					reloading = false
					relaod_progress = reload_speed
					bullets = max_bullets

func shoot(bullet_velocity, bullet_start):
	if do_shoot and !reloading and !fire_coolingdown:
		bulletSound.rpc()
		bullets -= 1
		fire_coolingdown = true
		if bullets <= 0:
			reloading = true
		
		do_shoot = false
		var bulleteInstance = BULLET.instantiate()
		bulleteInstance.position = bullet_start
		bulleteInstance.linear_velocity = bullet_velocity
		get_parent().get_parent().get_node("Bullets").add_child(bulleteInstance, true)
		
		bulleteInstance.modifyBulletVariables(damage, bullet_bounces, bullet_size)


func handleGravity(delta):
	# Handle gravity
	if not is_on_floor() and velocity.y <= TERMINAL_VELOCITY:
		# Handle wall slide
		if is_on_wall() and velocity.y >= 0:
			velocity.y = move_toward(velocity.y, WALL_SLIDE_VELOCITY, speed)
		else:
			velocity.y += gravity * delta

func jump():
	# Handle jump. do_jump is handled by an rpc from the syncronizer
	if do_jump and is_on_floor():
		do_jump = false
		velocity.y = jump_velocity

func wallJump():
	# Handle wall jump logic
	if do_jump and is_on_wall():
		do_jump = false
		var collsion = get_slide_collision(0)
		velocity.x = collsion.get_normal().x * speed * 2
		velocity.y = jump_velocity * .8
	

func move():
	# Get the input direction from the snycronizer and handle the movement/deceleration.
	direction = $InputSyncronizer.input_direction
#	Update the syncronized is on floor variable with the current is on floor status
	_is_on_floor = is_on_floor()
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, speed / 2)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

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

@rpc("any_peer", "call_local")
func minusHealth(healthChange):
	health -= healthChange
	if health <= 0 && alive:
		health = 0
		setDead()
	texture_progress_bar.value = health

@rpc("any_peer", "call_local")
func bulletSound():
	bullet_audio.play()

func setDead():
	alive = false
	if multiplayer.is_server():
		rpc_switch_level.rpc()
			
@rpc("authority", "call_local")
func rpc_switch_level():
	gameManager.switch_level()

func setAlive():
	alive = true
	minusHealth(-max_health)
	
	respawn_timer = RESPAWN_TIMER_MAX

func modifyPlayerStats(stats: Dictionary):
	for stat_name in stats:
		if stat_name in self:  # Check if the player has the stat as a property
			#print('Player: %s' %player_id)
			#print('Old Stat: %s Stat Value: %s' % [stat_name, get(stat_name)])
			set(stat_name, get(stat_name) + stats[stat_name])
			#print("New Stat: %s Stat Value: %s" % [stat_name, get(stat_name)])
			
		else:
			print('Stat name does not exist on player object. stat_name: %s' %stat_name)
	
	

func movement(delta):
	handleGravity(delta)
	jump()
	move()
	wallJump()
	terminalVelocity()
