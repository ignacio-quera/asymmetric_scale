extends CharacterBody2D

signal hit

@export var SPEED = 100.0
@export var DASH_INVUL = 0.5
@export var player_id = 0
var dash_path: Curve2D = null
var time:float = 0
var screen_size
var dashing = false
var has_dashed = false

func _ready():
	# Set the initial velocity to zero.
	velocity = Vector2.ZERO
	screen_size = get_viewport_rect().size
	hide()
	
func start(pos, player_num):
	position = pos
	player_id = player_num
	$DashStatus.show()
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
			$DashStatus.hide()
			dashing_stretch(velocity)
			$AnimatedStamina.show()
			$AnimatedStamina.play()
			dash_path = Curve2D.new()
			dash_path.add_point(position)
			dash_path.add_point(position, velocity, velocity/2)
			dash_path.add_point(position + velocity/2)
			has_dashed = true
			dashing = true
	elif Input.is_action_just_pressed("action%s" % [player_id]) and velocity.length() <= 0:
		print("action")

	# Move the player.
	position += velocity * delta
	move_and_slide()

func _process(delta):
	if time >= DASH_INVUL:
		time = 0
		dash_path = null
		reset_scale()
	if dash_path != null:
		time += delta		
		print(time)
		if time < 0:
			position = dash_path.sample(0, 1 + time / 1)
		else:
			position = dash_path.samplef(1 + time / DASH_INVUL * (dash_path.point_count - 1))
		dashing = false
	
func dashing_stretch(vel):
	var direction_x = vel.x
	var direction_y = vel.y
	print("X:", direction_x)
	print("Y:", direction_y)
	if direction_x > 0 or direction_x < 0:
		$AnimatedSprite2D.scale.x *= 1.5
	elif direction_y < 0 or direction_y > 0:
		$AnimatedSprite2D.scale.y *= 1.5
		
	pass

func reset_scale():
	$AnimatedSprite2D.scale.x = 1
	$AnimatedSprite2D.scale.y = 1

func _on_dashing_timer_timeout():
	$AnimatedStamina.stop()
	$AnimatedStamina.hide()
	has_dashed = false
	$DashStatus.show()
