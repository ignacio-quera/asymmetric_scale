extends StaticBody2D

var picked = false
signal picked_signal
var picked_by
var t:float = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_size = get_viewport_rect().size
	position = Vector2(screen_size.x/2, screen_size.y/2)
	show()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	if picked:
		position = Vector2(picked_by.position.x, picked_by.position.y-10)
	else:
		$SpritePath/SpritePathFollow.progress = t * 10

func player_interact(player_area):
	if not picked:
		picked = true
		picked_by = player_area
		$CollisionShape2D.disabled = true
		picked_by.encumber()
		z_index = 1
	else:
		picked = false
		$CollisionShape2D.disabled = false
		picked_by.unencumber()
		picked_by = null
		z_index = 0
