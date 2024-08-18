extends StaticBody2D

var picked = false
# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_size = get_viewport_rect().size
	position = Vector2(screen_size.x/2, screen_size.y/2)
	show()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if picked:
		position = get_node("").global_position
	pass

func _on_area_2d_body_entered(body):
	print("entered")
	if body.get_parent().is_in_group("littleguy"):
		print("test")
