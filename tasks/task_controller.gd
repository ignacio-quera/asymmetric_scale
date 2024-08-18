extends Node2D

@export var magic_circle: PackedScene

func _ready():
	$task_spawn_timer.start()

func _on_task_spawn_timer_timeout():
	print(magic_circle)
	var task = magic_circle.instantiate()
	task.position = get_spawn_position()
	add_child(task)
	task.start()

func get_spawn_position():
	var centerpos = $task_spawn_area/CollisionShape2D.position + $task_spawn_area.position
	var size = $task_spawn_area/CollisionShape2D.shape.size
	var position_in_area = Vector2()
	position_in_area.x = (randf() * size.x) - (size.x/2) + centerpos.x 
	position_in_area.y = (randf() * size.y) - (size.y/2) + centerpos.y
	return position_in_area
