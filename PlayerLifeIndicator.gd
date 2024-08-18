extends TextureRect


const Player = preload("res://player.gd")

const alive = preload("res://assets/images/lilguyanimations/idle_animation/idle.png")
const dead = preload("res://assets/images/lilguyanimations/splats/neutral.png")


var is_alive: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var want_texture = (alive if is_alive else dead)
	if texture != want_texture:
		texture = want_texture
