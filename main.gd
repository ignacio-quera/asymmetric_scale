extends Node
@export var player_scene: PackedScene
func new_player(player_num):
	var Player = player_scene.instantiate()
	var player_spawn_location = $PlayerPath/PathPathLocation
	add_child(Player)
	Player.start(Vector2(player_num*10, player_num*10), player_num)
	#$Player.start($StartPosition.position+Vector2(player_num*10, player_num*10), player_num)

func new_game(number_of_players):
	for player in number_of_players:
		print(player)
		new_player(player)

func _ready():
	pass


func _on_hud_start_game():
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if event.is_action_pressed("ui_home"):
		new_game(2)

