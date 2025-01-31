extends Node

@onready var multyplayer_hud = $"MultyplayerHud"
@onready var current_level = $CurrentLevel
@onready var players = $Players
const level_folder_path = "res://scenes/levels"

var spawn_points : Array[Vector2] = []

var files = []

func _ready():
	get_level_files()

func become_host():
	MultiplayerManager.become_host()
	multyplayer_hud.hide()
	
func join_game():
	MultiplayerManager.join_game()
	multyplayer_hud.hide()

@rpc("authority", "call_local")
func switch_level_multiplayer(index : int):
	var level_scene = load(level_folder_path + '/' + files[index])
	var level_node = level_scene.instantiate()

	spawn_points = level_node.spawn_points
	var playerCount = players.get_child_count()
	for i in range(playerCount):
		players.get_child(i).position = spawn_points[i % playerCount]
	
	print(spawn_points)
	
	current_level.get_child(0).queue_free()

	current_level.call_deferred("add_child", level_node)
	
func switch_level():
	if not multiplayer.is_server():
		return # Only the server picks the level
	
	
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
