extends MultiplayerSynchronizer

@onready var player = $".."

var input_direction
var cursor_posiiton
# Called when the node enters the scene tree for the first time.
func _ready():
#	If the multiplayer authority is not equal to the current multiplayer id then disable the process
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
		
	input_direction = Input.get_axis("left", "right")

func _physics_process(delta):
	input_direction = Input.get_axis("left", "right")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
	if Input.is_action_just_pressed("fire"):
		fire.rpc()
	aim.rpc(player.cursor_position)
		
# rpc = remte procedure callw
@rpc("call_local")
func jump():
	if multiplayer.is_server() and player.alive:
		player.do_jump = true

@rpc("call_local")
func fire():
	if multiplayer.is_server() and player.alive:
		player.do_shoot = true
		
@rpc('call_local')
func aim(target):
	if player.alive:
		cursor_posiiton = target
		player.aim(cursor_posiiton)
