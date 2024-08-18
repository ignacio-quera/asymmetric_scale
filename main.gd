extends Node
@export var player_scene: PackedScene
var started = false;
var number_of_players: int;
signal paused
var camera;

func new_player(player_num):
	var player = player_scene.instantiate()
	var spawner = $PlayerPath
	var spawn_pos = spawner.position + spawner.curve.sample_baked(player_num * 20)
	add_child(player)
	var player_num_name = player_num+1
	player.name = "Player%s" % player_num_name
	player.start(spawn_pos, player_num)
	#$Player.start($StartPosition.position+Vectowr2(player_num*10, player_num*10), player_num)

func restart_game():
	get_tree().call_group("littleguy", "queue_free")
	get_tree().call_group("items", "queue_free")
	get_tree().paused = false
	for player in number_of_players:
		new_player(player)
	pass

func new_game(num):
	number_of_players = num
	for player in num:
		new_player(player)
	started = true

func _ready():
	pass


func _on_hud_start_game():
	pass # Replace with function body.


func _input(event):
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

