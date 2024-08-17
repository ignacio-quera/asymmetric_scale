extends CharacterBody2D

signal hit

@export var SPEED = 300.0
@export var player_id = 0
var screen_size
var dashing = false
var has_dashed = false
var dash_invulenarability = 30

func _ready():
	# Set the initial velocity to zero.
	velocity = Vector2.ZERO
	screen_size = get_viewport_rect().size
	hide()
	
func start(pos, player_num):
	position = pos
	player_id = player_num
	show()

func _physics_process(delta):
	# Get the input velocity and handle the movement/deceleration.
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("right%s" % [player_id]):
		velocity.x += 1
	if Input.is_action_pressed("left%s" % [player_id]):
		velocity.x -= 1
	if Input.is_action_pressed("up%s" % [player_id]):
		velocity.y -= 1
	if Input.is_action_pressed("down%s" % [player_id]):
		velocity.y += 1


	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
		var direction_x = velocity.x
		var direction_y = velocity.y
		if direction_x > 0:
			$AnimatedSprite2D.play("right")
		elif direction_x < 0:
			$AnimatedSprite2D.play("left")
		elif direction_y < 0:
			$AnimatedSprite2D.play("up")
		elif direction_y > 0:
			$AnimatedSprite2D.play("down")
	else:
		$AnimatedSprite2D.play("idle")
		
		
	if Input.is_action_just_pressed("action%s" % [player_id]) and velocity.length() > 0:
		if not has_dashed:
			$DashingResetTimer.start()
			dashing_stretch(velocity)
			$AnimatedStamina.play()
			position += velocity*10* delta
			position = position.clamp(
				Vector2.ZERO, screen_size
				)
			reset_scale()
			has_dashed = true
			dashing = true
	elif Input.is_action_just_pressed("action%s" % [player_id]) and velocity.length() <= 0:
		print("action")

	# Move the player.
	position += velocity * delta
	position = position.clamp(
		Vector2.ZERO, screen_size
		)

func _process(delta):
	pass
	
func dashing_stretch(vel):
	var direction_x = vel.x
	var direction_y = vel.y
	print("X:", direction_x)
	print("Y:", direction_y)
	if direction_x > 0:
		scale.x += 1
	#elif direction_x < 0:
	#elif direction_y < 0:
	#elif direction_y > 0:
	pass

func reset_scale():
	scale.x = 1
	scale.y = 1

func _on_dashing_timer_timeout():
	has_dashed = false
	dashing = false
	$AnimatedStamina.stop()
