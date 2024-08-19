extends Area2D


const STUN_TIME: float = 1


var radius: float
var deadly: int = 2
var pushed: Dictionary = {}


func start(pos):
	position = pos


# Called when the node enters the scene tree for the first time.
func _ready():
	radius = $CollisionShape2D.shape.radius
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	$GPUParticles2D.process_material = $GPUParticles2D.process_material.duplicate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	deadly -= 1
	radius += delta * 100
	$CollisionShape2D.shape.radius = radius
	$GPUParticles2D.process_material.emission_ring_radius = radius
	$GPUParticles2D.process_material.emission_ring_inner_radius = radius-4
	if radius > 500:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("littleguy"):
		if deadly > 0:
			body._kill()
		else:
			if not pushed.has(body.get_instance_id()):
				body._push((body.position - position).normalized() * 1000)
			pushed[body.get_instance_id()] = true
