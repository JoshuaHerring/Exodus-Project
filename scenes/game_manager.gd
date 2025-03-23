extends Node

@onready var card_manager = $CardManager
@onready var multyplayer_hud = $"MultyplayerHud"
@onready var current_level = $CurrentLevel
@onready var players = $Players
@onready var http_request = $HTTPRequest
@onready var background_music = $BackgroundMusic

const level_folder_path = "res://scenes/levels"
const api_url = 'https://exodus-project-backend.onrender.com'

var spawn_points : Array[Vector2] = []
var cardManagerOpen = false

var files = []
var roundVictorId = 0
var lastLevelId = 0

func _ready():
# You can make the request anywhere and the response is handled in the on request complete signal function below
	http_request.request(api_url + '/choice')
	get_level_files()

func become_host():
	MultiplayerManager.become_host()
	multyplayer_hud.hide()
	
func join_game():
	MultiplayerManager.join_game()
	multyplayer_hud.hide()

@rpc("authority", "call_local")
func switch_level_multiplayer(index : int):
	startCardManager()
	var level_scene = load(level_folder_path + '/' + files[index])
	var level_node = level_scene.instantiate()

	spawn_points = level_node.spawn_points
	var playerCount = players.get_child_count()
	for i in range(playerCount):
		players.get_child(i).position = spawn_points[i % playerCount]
		
	current_level.get_child(0).queue_free()

	current_level.call_deferred("add_child", level_node)
	
func switch_level():
	if !background_music.playing:
		background_music.play()
	if not multiplayer.is_server():
		return # Only the server picks the level

	# Filter out dead players form all players
	var living_players = players.get_children().filter(func(player): return player.alive)

	# If there is more than 1 living player return; not switching the level
	if living_players.size() > 1:
		return
		
	roundVictorId = living_players[0].player_id
	lastLevelId = 	current_level.get_child(0).id

	var index : int = randi() % files.size()
	switch_level_multiplayer.rpc(index)
	
# A helper function to gather all of the files in the levels folder
func get_level_files():
	var dir = DirAccess.open(level_folder_path)
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	
	while file_name != "":
		if !dir.current_is_dir():
			files.append(file_name)
		file_name = dir.get_next()
		
	dir.list_dir_end()
		
	return files

func startCardManager():
	cardManagerOpen = true
	card_manager.startCardManager()

func endCardManager():
	cardManagerOpen = false
	card_manager.endCardManager.rpc()




func _on_request_request_completed(result, response_code, headers, body):
#	Convert the encoded body to string from utf8 then parse the string to json data
	print(JSON.parse_string(body.get_string_from_utf8()))
