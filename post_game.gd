extends Node2D


var time := 0.0
var bigfella_wins: bool
var main_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	time = 0
	$CanvasLayer/Winner.text = ("Knight Wins" if bigfella_wins else "Critters Win")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if time >= 5:
		var main = main_scene.instantiate()
		main.stage = main.Stage.RAISING
		get_tree().get_child(0).queue_free()
		get_tree().root.add_child(main)
		get_tree().root.move_child(main, 0)
		get_tree().current_scene = main
