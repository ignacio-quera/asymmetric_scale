extends Area2D


var radius: float


func start(pos):
	position = pos


# Called when the node enters the scene tree for the first time.
func _ready():
	radius = $CollisionShape2D.shape.radius
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	$GPUParticles2D.process_material = $GPUParticles2D.process_material.duplicate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	radius += delta * 100
	$CollisionShape2D.shape.radius = radius
	$GPUParticles2D.process_material.emission_ring_radius = radius
	$GPUParticles2D.process_material.emission_ring_inner_radius = radius-4
	if radius > 500:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("littleguy"):
		body._stun(1)
