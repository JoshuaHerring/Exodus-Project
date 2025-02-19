extends Control

@onready var players = $"../../../Players"
@onready var game_manager = $"../../../"

var has_been_clicked = false
var card_data

func set_card_data(data):
	card_data = data
	$Title.text = card_data.title
	$Description.text = card_data.description
	$Type.text = str(card_data.type)
	
func _on_button_pressed():
	if !has_been_clicked:
		has_been_clicked = true
		request_button_click.rpc()
		game_manager.endCardManager()


@rpc("any_peer", "call_local")
func request_button_click():
	if multiplayer.is_server():
		var sender_id = multiplayer.get_remote_sender_id() # Get the id of who triggered the rpc
		if card_data.type == 1:
			var player = players.get_node(str(sender_id))
			player.modifyPlayerStats(card_data.stat_modifiers)
		else:
			for child in players.get_children():
				if child.name == str(sender_id):
					pass
				else:
					child.modifyPlayerStats(card_data.stat_modifiers)
