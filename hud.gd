extends CanvasLayer

signal start_game
var number_of_players = 2
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func ask_how_many_players():
	var dialog = $Dialog
	dialog.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_start_button_pressed():
	$StartButton.hide()
	$NumberOfPlayers.hide()
	start_game.emit(number_of_players)


func _on_number_of_players_item_selected(index):
	number_of_players = index + 1
	pass # Replace with function body.
	
func _on_pause():
	$UnpauseButton.show()
	$ExitButton.show()


func _on_unpause_button_pressed():
	$UnpauseButton.hide()
	$ExitButton.hide()	
	get_tree().paused = false
	pass # Replace with function body.



func _on_exit_button_pressed():
	get_tree().set_auto_accept_quit(false)
	pass # Replace with function body.
