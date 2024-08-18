extends Node


@export var bigfella_sprites: Array[Sprite2D]
@export var postgame_scene: PackedScene


var playing: bool = true
var time: float = 0
var health: int = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func finish_game():
	print("finished game")
	var postgame = postgame_scene.instantiate()
	postgame.bigfella_wins = (health <= 0)
	get_tree().root.get_child(0).queue_free()
	get_tree().root.add_child(postgame)
	get_tree().current_scene = postgame


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
			finish_game()


func _hurt_bigfella(amount: int = 1):
	health -= amount
	get_viewport().get_camera_2d().apply_shake(1)
	if health <= 0:
		playing = false
		time = 0
