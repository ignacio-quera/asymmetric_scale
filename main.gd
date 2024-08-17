extends Node
@export var player_scene: PackedScene
var started = false;
signal paused

func new_player(player_num):
	var player = player_scene.instantiate()
	var spawner = $PlayerPath
	var spawn_pos = spawner.position + spawner.curve.sample_baked(player_num * 20)
	add_child(player)
	player.start(spawn_pos, player_num)
	#$Player.start($StartPosition.position+Vector2(player_num*10, player_num*10), player_num)

func new_game(number_of_players):
	for player in number_of_players:
		print(player)
		new_player(player)
	started = true

func _ready():
	pass


func _on_hud_start_game():
	pass # Replace with function body.


func _input(event):
	#if event.is_action_pressed("ui_cancel"):
		#get_tree().quit()
	if event.is_action_pressed("ui_home"):
		new_game(2)
	if event.is_action_pressed("menu"):
		pause()
		
func quit():
	get_tree().quit()
		
func pause():
	if started:
		get_tree().paused = true
		paused.emit()

func unpause():
	get_tree().paused = false
