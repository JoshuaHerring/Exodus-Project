extends Control

const CARD = preload("res://scenes/card.tscn")
@onready var h_box_cards = $HBoxCards
var card_pool = []

# Called when the node enters the scene tree for the first time.
func _ready():
	load_cards_from_json("res://resources/cards.json")

# Load card data from the JSON file
func load_cards_from_json(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var parsed = json.parse(content)
	
	card_pool = json.get_data()

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

	var shuffled = card_pool.duplicate()
	shuffled.shuffle()
	var selected_cards = shuffled.slice(0, count)
	
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
	for child in h_box_cards.get_children():
		child.queue_free()
	
	# Display the received cards
	for cardData in selected_cards:
		var card = CARD.instantiate()
		card.set_card_data(cardData)
		h_box_cards.add_child(card)
