extends Control

const CARD = preload("res://scenes/card.tscn")
@onready var h_box_reinforcements = $HBoxReinforcements
@onready var h_box_punishments = $HBoxPunishments

#var card_pool = []
var card_pool = {
	"reinforcements": [],
	"punishments": []
}


# Called when the node enters the scene tree for the first time.
func _ready():
	load_cards_from_json("res://resources/cards.json")

# Load card data from the JSON file
func load_cards_from_json(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var parsed = json.parse(content)
	var data = json.get_data()
	
	card_pool["reinforcements"] = data["reinforcements"]
	card_pool["punishments"] = data["punishments"]

# Function that runs when the button is clicked
func startCardManager():
	show()
	get_random_cards(4)

@rpc("any_peer", "call_local")
func endCardManager():
	hide()

# Only the server selects the cards and sends them to clients
func get_random_cards(count: int):
	if not multiplayer.is_server():
		return # Only the server should select cards

	var shuffledReinforcments = card_pool["reinforcements"].duplicate()
	shuffledReinforcments.shuffle()
	var selected_reinforcements = shuffledReinforcments.slice(0, count)
	
	var shuffledPunishments = card_pool["punishments"].duplicate()
	shuffledPunishments.shuffle()
	var selected_punishments = shuffledPunishments.slice(0, count)
	
	var selected_cards = {
	"reinforcements": selected_reinforcements,
	"punishments": selected_punishments
}
	
	# Share the selected cards with all clients
	share_selected_cards.rpc(selected_cards)

# The server sends the selected cards to all clients
@rpc("authority", "call_local")
func share_selected_cards(selected_cards):
	for player_id in multiplayer.get_peers():
		rpc_id(player_id, "display_selected_cards", selected_cards)

# Clients receive the selected cards and display them
@rpc("any_peer", "call_local")
func display_selected_cards(selected_cards):
	# Clear old cards before adding new ones
	for child in h_box_reinforcements.get_children():
		child.queue_free()
		
	for child in h_box_punishments.get_children():
		child.queue_free()
	
	
	# Display the received cards
	for cardData in selected_cards["reinforcements"]:
		var card = CARD.instantiate()
		card.set_card_data(cardData)
		h_box_reinforcements.add_child(card)
		
	for cardData in selected_cards["punishments"]:
		var card = CARD.instantiate()
		card.set_card_data(cardData)
		h_box_punishments.add_child(card)
