extends CanvasLayer


signal exit_game
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("menu"):
		$UnpauseButton.hide()
		$ExitButton.hide()
		get_tree().paused = false
		
func _on_pause():
	$UnpauseButton.show()
	$ExitButton.show()

func _on_unpause_button_pressed():
	$UnpauseButton.hide()
	$ExitButton.hide()	
	get_tree().paused = false
	pass # Replace with function body.

func _on_exit_button_pressed():
	exit_game.emit() 
