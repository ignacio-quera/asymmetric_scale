extends CharacterBody2D

signal hit

@export var SPEED = 100.0
@export var DASH_INVUL = 0.7
@export var player_id = 0
var player_num: int
var dash_path: Curve2D = null
var time: float = 0
var screen_size
var dashing = false
var has_dashed = false
var objects_in_contact: Dictionary = {}
var carrying: WeakRef = WeakRef.new()
var helpless: bool = false
var celebrating: bool = false

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
	
	var vel = Vector2.ZERO
	# Get the input velocity and handle the movement/deceleration.
	if not helpless:
		if Input.is_action_pressed("right%s" % [player_id]):
			vel.x += 1
		if Input.is_action_pressed("left%s" % [player_id]):
			vel.x -= 1
		if Input.is_action_pressed("up%s" % [player_id]):
			vel.y -= 1
		if Input.is_action_pressed("down%s" % [player_id]):
			vel.y += 1

		if vel.length() > 0:
			vel = vel.normalized() * SPEED
			var direction_x = vel.x
			var direction_y = vel.y
			if direction_x > 0:
				$AnimatedSprite2D.play("right")
			elif direction_x < 0:
				$AnimatedSprite2D.play("left")
			elif direction_y < 0:
				$AnimatedSprite2D.play("up")
			elif direction_y > 0:
				$AnimatedSprite2D.play("down")
		elif celebrating:
			$AnimatedSprite2D.play("celebrate")
		else:
			$AnimatedSprite2D.play("idle")

		if Input.is_action_just_pressed("action%s" % [player_id]) and vel.length() > 0:
			if not has_dashed:
				$DashingResetTimer.start()
				$CollisionShape2D.disabled = true
				$DashStatus.hide()
				dashing_stretch(vel)
				$AnimatedStamina.show()
				$AnimatedStamina.play()
				dash_path = Curve2D.new()
				dash_path.add_point(position)
				dash_path.add_point(position, vel, vel/2)
				dash_path.add_point(position + vel/2)
				has_dashed = true
				dashing = true
		elif Input.is_action_just_pressed("action%s" % [player_id]) and vel.length() <= 0:
			var max_dist = INF
			var closest = null
			for id in objects_in_contact:
				var obj = objects_in_contact[id]
				if not obj.has_method("player_interact"):
					obj = obj.get_parent()
				if not obj.has_method("player_interact"):
					continue
				var d = (obj.global_position - global_position).length()
				if d < max_dist:
					max_dist = d
					closest = obj
			if closest != null:
				closest.player_interact(self)

		if carrying.get_ref() != null:
			vel /= 2

	# Move the player.
	position += vel * delta
	move_and_slide()


func _process(delta):
	if time >= DASH_INVUL:
		time = 0
		dash_path = null
		dashing = false
		$CollisionShape2D.disabled = false
		reset_scale()
	if dash_path != null:
		time += delta
		if time < 0:
			position = dash_path.sample(0, 1 + time / 1)
		else:
			position = dash_path.samplef(1 + time / DASH_INVUL * (dash_path.point_count - 1))
	
func dashing_stretch(vel):
	var direction_x = vel.x
	var direction_y = vel.y
	if direction_x > 0 or direction_x < 0:
		$AnimatedSprite2D.scale.x *= 1.5
	elif direction_y < 0 or direction_y > 0:
		$AnimatedSprite2D.scale.y *= 1.5
		
	pass

func carrying_squish():
	$AnimatedSprite2D.scale.y *= 0.5 
	pass
	
func carrying_unsquish():
	$AnimatedSprite2D.scale.y *= 2

func reset_scale():
	$AnimatedSprite2D.scale.x = 1
	$AnimatedSprite2D.scale.y = 1

func unencumber():
	var item = carrying.get_ref()
	if item != null:
		item.picked_by = WeakRef.new()
	carrying = WeakRef.new()
	has_dashed = false
	#carrying_unsquish()
	
func encumber(item):
	item.picked_by = weakref(self)
	carrying = weakref(item)
	#has_dashed = true
	#carrying_squish()
	
func _on_dashing_timer_timeout():
	$AnimatedStamina.stop()
	$AnimatedStamina.hide()
	has_dashed = false
	$DashStatus.show()


func _on_interact_area_area_entered(area):
	objects_in_contact[area.get_instance_id()] = area
	if area.has_method("player_interact_enter"):
		area.player_interact_enter(self)
	if area.get_parent().has_method("player_interact_enter"):
		area.get_parent().player_interact_enter(self)


func _on_interact_area_area_exited(area):
	objects_in_contact.erase(area.get_instance_id())
	if area.has_method("player_interact_exit"):
		area.player_interact_exit(self)
	if area.get_parent().has_method("player_interact_exit"):
		area.get_parent().player_interact_exit(self)

func _kill():
	if helpless:
		return
	if carrying.get_ref():
		unencumber()
	$/root/Main/GameMaster._player_died(player_num)
	queue_free()

func _celebrate():
	celebrating = true
