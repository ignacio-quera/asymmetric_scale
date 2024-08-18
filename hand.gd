extends Area2D

@export var is_left: bool
@export var recover_pos: Marker2D
@export var hand_texture: Texture2D

const SETUP_TIME: float = 1
const RECOVER_TIME: float = 1
const RECOVER_GRACE: float = 0.7

enum Action {SWIPE, BACKHAND, FIST, CLAW, PUNCH}
var follow_curve: Curve2D = null
var recovering: bool = false
var time: float = 0
var max_time: float = 0
var deadly: bool = false
var shake_hit: float = 0
var constant_shake: float = 0

func ready_to_attack():
	return follow_curve == null or (recovering and time >= max_time - RECOVER_GRACE)

func do_action(act: Action, pos: Vector2):
	var scrsize = get_viewport_rect().size
	var forward = (1 if is_left else -1)
	const MARGIN = 70
	time = -SETUP_TIME
	follow_curve = Curve2D.new()
	follow_curve.add_point(position)
	recovering = false
	match act:
		Action.FIST:
			follow_curve.add_point(pos + Vector2.UP*100)
			follow_curve.add_point(pos, Vector2.UP*100)
			max_time = 1
			shake_hit = 1
		Action.SWIPE:
			follow_curve.add_point(Vector2(scrsize.x*(1-forward)/2, pos.y))
			follow_curve.add_point(Vector2(scrsize.x*(1+forward)/2+MARGIN*forward, pos.y), Vector2.LEFT*100*forward)
			max_time = 1
			deadly = true
		Action.BACKHAND:
			follow_curve.add_point(Vector2(scrsize.x*(1+forward)/2, pos.y))
			follow_curve.add_point(Vector2(scrsize.x*(1-forward)/2-MARGIN*forward, pos.y), -Vector2.LEFT*100*forward)
			max_time = 2
			deadly = true
			constant_shake = 0.5
		Action.CLAW:
			follow_curve.add_point(Vector2(pos.x, 0))
			follow_curve.add_point(Vector2(pos.x, scrsize.y+MARGIN), Vector2.UP*100)
			max_time = 1
			deadly = true
		Action.PUNCH:
			follow_curve.add_point(Vector2(pos.x, scrsize.y))
			follow_curve.add_point(Vector2(pos.x, -MARGIN), -Vector2.UP*100)
			max_time = 1
			deadly = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.texture = hand_texture
	if is_left:
		scale.x *= -1
	position = recover_pos.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if follow_curve != null:
		time += delta
		if time < 0:
			position = follow_curve.sample(0, 1 + time / SETUP_TIME)
		else:
			var n = follow_curve.point_count - 2
			position = follow_curve.samplef(1 + time / max_time * n)
			if constant_shake > 0:
				get_viewport().get_camera_2d().apply_shake(constant_shake)
		if time >= max_time:
			if shake_hit > 0:
				get_viewport().get_camera_2d().apply_shake(shake_hit)
				shake_hit = 0
			constant_shake = 0
			if recovering:
				follow_curve = null
				recovering = false
			else:
				follow_curve = Curve2D.new()
				follow_curve.add_point(position)
				follow_curve.add_point(position)
				follow_curve.add_point(recover_pos.position)
				time = 0
				max_time = RECOVER_TIME
				recovering = true
				deadly = false
	$CollisionShape2D.disabled = not deadly or time < 0


func _on_body_entered(body):
	if body.is_in_group("littleguy"):
		body.queue_free()
