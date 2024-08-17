extends Node2D

@export var magic_circle: PackedScene

func _ready():
	_on_task_spawn_timer_timeout()
	$task_spawn_timer.start()
	
	var task_spawn_timer = get_node("task_spawn_timer")
	task_spawn_timer.timeout.connect(_on_task_spawn_timer_timeout)

func _on_task_spawn_timer_timeout():
	print(magic_circle)
	var task = magic_circle.instantiate()
	task.position = get_spawn_position()
	add_child(task)

func get_spawn_position():
	var centerpos = $task_spawn_area/CollisionShape2D.position + $task_spawn_area.position
	var size = $task_spawn_area/CollisionShape2D.shape.size
	var position_in_area = Vector2()
	position_in_area.x = (randf() * size.x) - (size.x/2) + centerpos.x 
	position_in_area.y = (randf() * size.y) - (size.y/2) + centerpos.y
	return position_in_area

