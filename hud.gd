extends CanvasLayer

signal start_game

var number_of_players: int

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_player_count(2)

func _on_start_button_pressed():
	start_game.emit(number_of_players - 1)

func _on_number_of_players_item_selected(index):
	number_of_players = index + 1
	pass # Replace with function body.


func _set_player_count(player_count: int):
	number_of_players = player_count
	for btn: Button in $PlayerCount.get_children():
		btn.disabled = (btn.text == str(player_count))
