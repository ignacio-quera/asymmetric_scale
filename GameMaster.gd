extends Node


@export var bigfella_sprites: Array[Sprite2D]


var playing: bool = true
var time: float = 0
var health: int = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if playing:
		pass
	else:
		get_viewport().get_camera_2d().apply_shake(0.6)
		for sprite in bigfella_sprites:
			sprite.position.y += delta * 10
		var t = (time - 5) / 5
		$FadeToBlack.visible = true
		$FadeToBlack.color.a = clamp(t, 0, 1)
		if t >= 1.5:
			# Finish game
			print("finished game")
			get_tree().change_scene_to_file("res://post_game.tscn")


func _hurt_bigfella(amount: int = 1):
	health -= amount
	get_viewport().get_camera_2d().apply_shake(1)
	if health <= 0:
		playing = false
		time = 0
