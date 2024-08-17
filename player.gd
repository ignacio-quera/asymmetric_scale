extends CharacterBody2D

signal hit

@export var SPEED = 300.0
@export var player_id = 0
var screen_size
var dashing = false
var dashing_delay = 500
var has_dashed = false

func _ready():
	# Set the initial velocity to zero.
	velocity = Vector2.ZERO
	screen_size = get_viewport_rect().size
	$DashingTimer.process_callback = $AnimatedStamina.frame
	#print($AnimatedStamina.frame)
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
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	if Input.is_action_just_pressed("action%s" % [player_id]) and velocity.length() > 0:
		if not has_dashed:
			position += velocity*10* delta
			position = position.clamp(
				Vector2.ZERO, screen_size
				)
			$AnimatedStamina.play()
			has_dashed = true
			dashing = true
			$DashingTimer.start()
	elif Input.is_action_just_pressed("action%s" % [player_id]) and velocity.length() <= 0:
		print("action")

	# Move the player.
	position += velocity * delta
	position = position.clamp(
		Vector2.ZERO, screen_size
		)

func _process(delta):
	pass

func _on_dashing_timer_timeout():
	dashing = false
	has_dashed = false
