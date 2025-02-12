extends Control

@onready var players = $"../../../Players"

var has_been_clicked = false
var card_data

func set_card_data(data):
	card_data = data
	print(card_data)
	$Title.text = card_data.title
	$Description.text = card_data.description

func _on_button_pressed():
	if !has_been_clicked:
		has_been_clicked = true
		request_button_click.rpc()


@rpc("any_peer", "call_local")
func request_button_click():
	if multiplayer.is_server():
		var sender_id = multiplayer.get_remote_sender_id() # Get the id of who triggered the rpc
		print("Button clicked by player ID:", sender_id)
		var player = players.get_node(str(sender_id))
		player.speed = 1000
		#apply_effect(sender_id)

func apply_effect(player_id):
	for stat in card_data.stat_modifiers:
		print(stat)
		#PlayerStats.modify_stat(stat, card_data.stat_modifiers[stat])
