extends Node

const SERVER_PORT = 8080
# Change this to ipv_4 for it to work across devices on same network?
const SERVER_IP = "127.0.0.1"
# REMEMBER THIS IS A GLOBAL SCRIPT THAT CAN BE ACCESSED FORM ANYWHERE BY TYPING IN THE NAME OF THE FILE THEN A PERIOD

# Used to keep track of if the there is a host and if you are the host
var host_mode_enabled = false
# variable to tell if multiplayer is enabled
var multiplayer_mode = false
var multiplayer_scene = preload("res://scenes/multiplayer_player.tscn")
var _players_spawn_node 

func become_host():
	
	host_mode_enabled = true
	multiplayer_mode = true
	
	_players_spawn_node = get_tree().get_current_scene().get_node("Players")
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)
	
	#_remove_single_player()
	
	_add_player_to_game(1)
	
func join_game():
	multiplayer_mode = true
	var clinet_peer = ENetMultiplayerPeer.new()
	clinet_peer.create_client(SERVER_IP, SERVER_PORT)
	
	multiplayer.multiplayer_peer = clinet_peer
	
	#_remove_single_player()


func _add_player_to_game(id: int):
	print("Player %s has joined the game!" % id)
	var player_to_add = multiplayer_scene.instantiate()
	
	player_to_add.player_id = id
	player_to_add.name = str(id)

	_players_spawn_node.add_child(player_to_add, true)
	
	

func _del_player(id: int):
	#print("Player %s has left the game!" % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()
	
	
func _remove_single_player():
#	There used to be a single player node but that has been removed
	var player_to_remove = get_tree().get_current_scene().get_node("Player")
	player_to_remove.queue_free()
