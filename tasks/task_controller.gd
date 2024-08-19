extends Node2D

@export var task_scenes: Array[PackedScene]

var task_order: Array[int] = []
var next_task: int = 0

func _ready():
	randomize()
	for i in len(task_scenes):
		task_order.append(i)
	task_order.shuffle()

func _on_task_spawn_timer_timeout():
	var task = task_scenes[task_order[next_task]].instantiate()
	next_task = (next_task + 1) % len(task_order)
	task.position = get_spawn_position()
	add_child(task)
	task.start()

func new_task():
	$task_spawn_timer.start()

func get_spawn_position():
	var centerpos = $task_spawn_area/CollisionShape2D.position + $task_spawn_area.position
	var size = $task_spawn_area/CollisionShape2D.shape.size
	var position_in_area = Vector2()
	position_in_area.x = (randf() * size.x) - (size.x/2) + centerpos.x 
	position_in_area.y = (randf() * size.y) - (size.y/2) + centerpos.y
	return position_in_area
