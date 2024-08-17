extends Area2D


@export var is_left: bool

const SETUP_TIME: float = 1

enum Action {SWIPE, BACKHAND, FIST, CLAW, PUNCH}

var follow_curve: Curve2D = null
var time: float = 0
var max_time: float = 0
var deadly: bool = false

func ready_to_attack():
	return follow_curve == null

func do_action(act: Action, pos: Vector2):
	var scrsize = get_viewport_rect().size
	match act:
		Action.FIST:
			follow_curve = Curve2D.new()
			follow_curve.add_point(position)
			follow_curve.add_point(pos + Vector2.UP*100)
			follow_curve.add_point(pos, Vector2.UP*100)
			time = -SETUP_TIME
			max_time = 1
		Action.SWIPE:
			var forward = (1 if is_left else -1)
			follow_curve = Curve2D.new()
			follow_curve.add_point(position)
			follow_curve.add_point(Vector2(scrsize.x*(1-forward)/2, pos.y))
			follow_curve.add_point(Vector2(scrsize.x*(1+forward)/2+100*forward, pos.y), Vector2.LEFT*100*forward)
			time = -SETUP_TIME
			max_time = 1
			deadly = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.flip_h = is_left


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if time >= max_time:
		time = 0
		follow_curve = null
		deadly = false
	$CollisionShape2D.disabled = not deadly or time < 0
	if follow_curve != null:
		if time < 0:
			position = follow_curve.sample(0, 1 + time / SETUP_TIME)
		else:
			position = follow_curve.samplef(1 + time / max_time * (follow_curve.point_count - 1))


func _on_body_entered(body):
	if body.is_in_group("littleguy"):
		body.queue_free()
