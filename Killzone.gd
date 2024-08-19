extends Area2D
var body_to_kill;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("littleguy"):
		$KillTimer.set_wait_time(body.DASH_INVUL)
		if not body.dashing:
			body._kill()
		else:
			body_to_kill = body
			$KillTimer.start()
			
func _on_kill_timer_timeout():
	body_to_kill._kill()
