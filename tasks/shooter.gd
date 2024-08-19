extends Area2D

var launch_curve: Curve2D = null
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func player_interact(player):
	if $"..".cranked:
		$Line2D.show()
		$"..".aiming = player
		#player.helpless = true
