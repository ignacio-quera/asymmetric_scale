extends CanvasLayer


signal exit_game
signal reset_game
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("menu"):
		hide_buttons()
		get_tree().paused = false
		
func _on_pause():
	$UnpauseButton.show()
	$ExitButton.show()
	$ResetButton.show()

func _on_unpause_button_pressed():
	hide_buttons()
	get_tree().paused = false
	pass # Replace with function body.

func _on_exit_button_pressed():
	exit_game.emit() 


func _on_reset_button_pressed():
	hide_buttons()
	reset_game.emit()
	pass # Replace with function body.

func hide_buttons():
	$UnpauseButton.hide()
	$ExitButton.hide()
	$ResetButton.hide()
