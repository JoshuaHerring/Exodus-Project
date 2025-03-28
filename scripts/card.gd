extends Control

@onready var players = $"../../../Players"
@onready var game_manager = $"../../../"
@onready var card_manager = $"../../"

var has_been_clicked = false
var card_data


func set_card_data(data):
	card_data = data
	$Title.text = card_data.title
	$Description.text = card_data.description
	$Type.text = str(card_data.type)
	if card_data.type == 1:
		$ColorRect.color = Color("009d00")
	else: 
		$ColorRect.color = Color("92000d")
	
func _on_button_pressed():

	if !has_been_clicked:
		has_been_clicked = true
		request_button_click.rpc()


@rpc("any_peer", "call_local")
func request_button_click():
	if multiplayer.is_server():
		var sender_id = multiplayer.get_remote_sender_id() # Get the id of who triggered the rpc
		
#		If the winner did not click the button ignore
		if sender_id == game_manager.roundVictorId:
			return
			
		if card_data.type == 1:
			var player = players.get_node(str(sender_id))
			player.modifyPlayerStats.rpc(card_data.stat_modifiers)
		else:
			for player in players.get_children():
				if player.name == str(sender_id):
					pass
				else:
					player.modifyPlayerStats.rpc(card_data.stat_modifiers)
		
		var score = {"player1": 0, "player2": 0}
		if game_manager.lastLevelId !=0:
			sendChoiceData(game_manager.lastLevelId, card_data.type, game_manager.roundVictorId, score)
		game_manager.endCardManager()

func sendChoiceData(level_id, choice_type, player_id, score):
	if multiplayer.is_server():
		card_manager.sendChoiceData(level_id, choice_type, player_id, score)
		pass
#	 Add http request functionality in the cardManager and have this call that to avoid needing multiple httprequest nodes
