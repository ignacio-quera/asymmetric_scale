extends Area2D

var launch_curve: Curve2D = null
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func player_interact(player):
	#if $"..".cranked:
	$"..".aiming = player
		#player.helpless = true
		##launching = player
		#var guy = get_viewport_rect().size / 2
		#guy.y /= 3
		#var endpos = Vector2(2*guy.x - player.position.x, player.position.y)
		#launch_curve = Curve2D.new()
		#launch_curve.add_point(player.position, Vector2.ZERO, Vector2.UP*100)
		#launch_curve.add_point(guy)
		#launch_curve.add_point(endpos, guy-endpos)
		#time = -SETUP_TIME
