extends Node

@onready var multyplayer_hud = $"../MultyplayerHud"

func become_host():
	MultiplayerManager.become_host()
	#print('host')
	multyplayer_hud.hide()
	
func join_game():
	MultiplayerManager.join_game()
	#print('join')
	multyplayer_hud.hide()

	
