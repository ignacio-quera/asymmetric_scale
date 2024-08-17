extends CharacterBody2D


@export var SPEED = 300.0
@export var player_id = 0
var screen_size

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
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	if Input.is_action_just_pressed("action%s" % [player_id]) and velocity.length() > 0:
		position += velocity*10* delta
		position = position.clamp(
			Vector2.ZERO, screen_size
			)
	elif Input.is_action_just_pressed("action%s" % [player_id]) and velocity.length() <= 0:
		print("action")

	# Move the player.
	position += velocity * delta
	position = position.clamp(
		Vector2.ZERO, screen_size
		)

func _process(delta):
	pass
