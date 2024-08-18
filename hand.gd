extends Area2D

@export var color: String
@export var recover_pos: Marker2D
@export var hand_texture: Texture2D
@export var shockwave_scene: PackedScene
@export var flick_scene: PackedScene

const RECOVER_GRACE: float = 0.7

enum Action {SWIPE, CLAW, FIST, FLICK, SWAB}
var follow_curve: Curve2D = null
var recovering: bool = false
var time: float = 0
var setup_time: float
var recover_time: float
var max_time: float = 0
var deadly: bool = false
var shake_hit: float = 0
var constant_shake: float = 0
var doing_action: Action

func ready_to_attack():
	return follow_curve == null or (recovering and time >= max_time - RECOVER_GRACE)

func do_action(act: Action, pos: Vector2):
	var scrsize = get_viewport_rect().size
	var forward = (1 if color == 'red' else -1)
	const MARGIN = 70
	follow_curve = Curve2D.new()
	follow_curve.add_point(position)
	recovering = false
	doing_action = act
	setup_time = 1
	recover_time = 1
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
		Action.CLAW:
			follow_curve.add_point(Vector2(scrsize.x*(1+forward)/2, pos.y))
			follow_curve.add_point(Vector2(scrsize.x*(1-forward)/2-MARGIN*forward, pos.y), -Vector2.LEFT*100*forward)
			max_time = 2
			deadly = true
			constant_shake = 0.5
		Action.FLICK:
			follow_curve.add_point(pos, Vector2.UP*10)
			max_time = 0.01
			setup_time = 0.4
			recover_time = 2
		Action.SWAB:
			follow_curve.add_point(Vector2(pos.x, scrsize.y))
			follow_curve.add_point(Vector2(pos.x, -MARGIN), -Vector2.UP*100)
			max_time = 1
			deadly = true
	time = -setup_time

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play('fist_%s' % color)
	if color == 'red':
		scale.x *= -1
	position = recover_pos.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var idle_anim := true
	if follow_curve != null:
		time += delta
		if time < 0:
			position = follow_curve.sample(0, 1 + time / setup_time)
			if not recovering and doing_action == Action.FLICK:
				$AnimatedSprite2D.play('flick_1_%s' % color)
				$AnimatedSprite2D.offset.y = -50
				idle_anim = false
		else:
			if doing_action == Action.FLICK:
				$AnimatedSprite2D.play('flick_2_%s' % color)
				idle_anim = false
			var n = follow_curve.point_count - 2
			position = follow_curve.samplef(1 + time / max_time * n)
			if constant_shake > 0:
				get_viewport().get_camera_2d().apply_shake(constant_shake)
		if time >= max_time:
			if shake_hit > 0:
				get_viewport().get_camera_2d().apply_shake(shake_hit)
				shake_hit = 0
			constant_shake = 0
			#$AnimatedSprite2D.play('fist_%s' % color)
			if recovering:
				follow_curve = null
				recovering = false
			else:
				match doing_action:
					Action.FIST:
						var shockwave = shockwave_scene.instantiate()
						shockwave.start(position)
						$/root/Main.add_child(shockwave)
					Action.FLICK:
						var flick = flick_scene.instantiate()
						flick.start(position)
						$/root/Main.add_child(flick)
				follow_curve = Curve2D.new()
				follow_curve.add_point(position)
				follow_curve.add_point(position)
				follow_curve.add_point(recover_pos.position)
				time = 0
				max_time = recover_time
				recovering = true
				deadly = false
	$CollisionShape2D.disabled = not deadly or time < 0
	if idle_anim:
		$AnimatedSprite2D.play('fist_%s' % color)
		$AnimatedSprite2D.offset = Vector2.ZERO


func _on_body_entered(body):
	if body.is_in_group("littleguy"):
		body._kill()
