extends Control


const Player = preload("res://player.gd")


@export var indicator_scene: PackedScene

var max_lives: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _update_lives_left(lives_left: int):
	while lives_left > get_child_count():
		var indicator = indicator_scene.instantiate()
		add_child(indicator)
	for i in get_child_count():
		get_child(i).is_alive = (i < lives_left)
