extends Area2D


var time: float = 0
var deadly := 2


func start(pos):
	position = pos


# Called when the node enters the scene tree for the first time.
func _ready():
	time = 0
	$GPUParticles2D.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	deadly -= 1


func _on_body_entered(body):
	if deadly > 0 and body.is_in_group("littleguy"):
		body._kill()
