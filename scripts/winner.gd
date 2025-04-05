extends ColorRect
@onready var timer = $Timer
@onready var winner = $Winner
@onready var loser = $Loser


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func display(winner_id):
	winner.text = "Player %s Won" % str(winner_id).substr(0, 3)
	show()
	timer.start()

func _on_timer_timeout():
	hide()
	timer.wait_time = 2.5
