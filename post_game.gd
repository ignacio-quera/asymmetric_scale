extends Node2D

var time := 0.0
var bigfella_wins: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	time = 0
	$CanvasLayer/Winner.text = ("Knight Wins" if bigfella_wins else "Critters Win")

func back_to_main_menu():
	var maingame = ResourceLoader.load("res://main.tscn").instantiate()
	maingame.stage = maingame.Stage.RAISING
	get_tree().root.get_child(0).queue_free()
	get_tree().root.add_child(maingame)
	get_tree().root.move_child(maingame, 0)
	get_tree().current_scene = maingame

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_continue_pressed():
	back_to_main_menu()
