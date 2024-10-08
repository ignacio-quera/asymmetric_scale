extends StaticBody2D
@export var item_scene: PackedScene
@export var shooter_rotation = 1 
@export var load_time = 0.2
@export var hit_curve:Curve
@export var miss_curve:Curve

var curve: Curve
var curve_len_time: float

const Player = preload("res://player.gd")

var min_rotation = -20
var max_rotation = 20
var picked_by:WeakRef = WeakRef.new()
var launching: Player = null
var aiming: Player = null
var raycast: RayCast2D
var launch_curve: Curve2D
var time: float = 0
var arrival_pos
var arriving = true;
var leaving = false;
var holder
var rope_state = 2
var cranked = false
var current_load_time = 0
var dead = false

# Called when the node enters the scene tree for the first time.
func start():
	arrival_pos = position
	position = Vector2(600,position.y)
	raycast = $"shooter/RayCast2D"
	
func _process(delta):
	if aiming != null:
		aiming.global_position = $"shooter/LaunchingNode".global_position
		aiming.z_index = 6
		aiming.helpless = true
		if current_load_time <= load_time:
			current_load_time += delta
			return
		if Input.is_action_pressed("right%s" % [aiming.player_id]):
			if $"shooter".rotation_degrees <= max_rotation:
				$"shooter".rotation += delta * shooter_rotation
		if Input.is_action_pressed("left%s" % [aiming.player_id]):
			if $"shooter".rotation_degrees >= min_rotation:
				$"shooter".rotation -= delta * shooter_rotation
		if Input.is_action_pressed("action%s" % [aiming.player_id]):
			current_load_time = 0
			launching = aiming
			aiming = null
			launch_curve = Curve2D.new()
			launch_curve.add_point(launching.global_position)
			if raycast.get_collider() != null:
				if raycast.get_collider().name == "BigFellaCollision":
					var target_pos = raycast.get_collider().global_position
					launch_curve.add_point(target_pos)
					curve = hit_curve
					curve_len_time = 0.8
				else:
					var target_pos = raycast.get_collision_point()
					launch_curve.add_point(target_pos)
					curve = miss_curve
					curve_len_time = 0.4
				time = 0
				$FireSound.play()
		elif Input.is_action_pressed("up%s" % [aiming.player_id]):
			current_load_time = 0
			aiming.helpless = false
			aiming = null
	if launching != null:
		time += delta
		var t = curve.sample(time / curve_len_time)
		launching.position = launch_curve.sample_baked(t * launch_curve.get_baked_length())
		if time >= 1:
			time = 0
			if curve == hit_curve:
				leaving = true
				$shooter.z_index = 0
				get_tree().call_group("gamemaster", "_hurt_bigfella")
				launching.helpless = false
				launching = null
			else:
				launching.helpless = false
				launching._kill()
				launching = null
			$shooter/Line2D.hide()
	$shooter/InteractableGlow.visible = cranked and not aiming and not launching and not leaving

func _physics_process(delta):
	if arriving:
		position.x -= 1
		$"Wheel".rotation -= 0.05
		$"Wheel2".rotation -= 0.05
		$"Wheel3".rotation -= 0.05
		$"Wheel4".rotation -= 0.05
	if floor(position.x) == floor(arrival_pos.x) and arriving:
		arriving = false
		spawn_crank()
		arrival_pos = Vector2(0,0)
	if picked_by.get_ref():
		global_position = picked_by.get_ref().position - holder.position
	if leaving:
		if position.x > -100:
			position.x -= 1
			$"CrankItem".position.x -= 1
			$"CrankItem".z_index = 1
			$"Wheel".rotation -= 0.05
			$"Wheel2".rotation -= 0.05
			$"Wheel3".rotation -= 0.05
			$"Wheel4".rotation -= 0.05

func _ready():
	pass # Replace with function body.cranked

func spawn_crank():
	var item = item_scene.instantiate()
	item.name = "CrankItem"
	item.compatible_slot = "Crank"
	item.get_node("SpritePath/SpritePathFollow/Sprite2D").texture = load("res://assets/images/tasks/crank.png")
	add_child(item)
	var gotten = get_item_spawn_position()
	item.position = gotten
	item.top_level = true
	item.global_position = gotten
	

func get_item_spawn_position():
	var centerpos = $item_spawn_area/CollisionShape2D.position + $item_spawn_area.position
	var size = $item_spawn_area/CollisionShape2D.shape.size
	var position_in_area = Vector2()
	position_in_area.x = (randf() * size.x) - (size.x/2) + centerpos.x 
	position_in_area.y = (randf() * size.y) - (size.y/2) + centerpos.y
	while (abs(position_in_area.x - position.x) < 65):
		position_in_area.x = (randf() * size.x) - (size.x/2) + centerpos.x 
		##position_in_area.y = (randf() * size.y) - (size.y/2) + centerpos.y
	return position_in_area

func crank():
	if rope_state < 8:
		var cranky = floor(rope_state)
		$shooter/String.texture = load("res://assets/images/tasks/strings/string%s.png" % cranky)
		rope_state += 0.5
		if !$CrankSound.playing:
			$CrankSound.play()
	else:
		$CrankItem/CollisionShape2D.disabled = true
		$CrankItem.interactable = false
		cranked = true
		$shooter/String.texture = load("res://assets/images/tasks/strings/string8.png")
