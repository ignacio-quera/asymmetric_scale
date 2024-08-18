extends Node

@export var anim_speed: float = 1
@export var player_scene: PackedScene
@export var hand_controller_scene: PackedScene
@export var invisible_when_raising: Array
@export var hand_spawners: Array[Node2D]
@export var big_fella: Array[Node2D]

signal paused

enum Stage { RAISING, MENU, LOWERING, SPAWNING, PLAYING }

var stage := Stage.MENU
var number_of_players: int
var time := 0.0
var last_t := 0.0
var big_fella_head_ready := true

var og_camera_offset: float

func new_player(player_num):
	var player = player_scene.instantiate()
	var spawner = $PlayerPath
	var spawn_pos = spawner.position + spawner.curve.sample_baked(player_num * 20)
	add_child(player)
	var player_num_name = player_num+1
	player.name = "Player%s" % player_num_name
	player.start(spawn_pos, player_num)

func new_game(num):
	number_of_players = num
	for player in num:
		new_player(player)
	stage = Stage.LOWERING

func start_game():
	$Camera2D.offset.y = 0
	# $ParallaxBackground/Background_Sky.motion_scale = Vector2.ONE * 0.1
	# $ParallaxBackground/Stage.motion_scale = Vector2.ONE
	for hand in hand_spawners:
		remove_child(hand)
	add_child(hand_controller_scene.instantiate())
	$GameMaster.process_mode = Node.PROCESS_MODE_INHERIT
	$GameMaster/task_controller.new_task()

func restart_game():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _ready():
	og_camera_offset = $Camera2D.offset.y
	hand_spawners = [$ParallaxBackground/HandSpawnL, $ParallaxBackground/HandSpawnR]
	big_fella = [$ParallaxBackground/BigFellaHead, $ParallaxBackground/BigFellaHelm]
	if stage == Stage.RAISING:
		for path in invisible_when_raising:
			get_node(path).visible = false
		time = 0.0
		$Camera2D.offset.y = 200

func _process(delta):
	match stage:
		Stage.RAISING:
			$Camera2D.offset.y -= delta * 100 * anim_speed
			if $Camera2D.offset.y <= og_camera_offset:
				$Camera2D.offset.y = og_camera_offset
				stage = Stage.MENU
				time = -1
		Stage.MENU:
			time += delta * anim_speed
			if time >= 0:
				for path in invisible_when_raising:
					get_node(path).visible = true
		Stage.LOWERING:
			$Camera2D.offset.y += delta * 50 * anim_speed
			if $Camera2D.offset.y >= 0:
				$Camera2D.offset.y = 0
				$Camera2D.enable_shake = true
				stage = Stage.SPAWNING
				time = -2
				big_fella_head_ready = false
				for fella in big_fella:
					fella.motion_offset.y = 100
		Stage.SPAWNING:
			time += delta * anim_speed
			var t = time / 3
			if t >= 1 and last_t < 1:
				get_viewport().get_camera_2d().apply_shake(1)
			last_t = t
			var diff = 0.1
			for i in range(len(hand_spawners)):
				var path = hand_spawners[i].get_node("Path")
				var i_f = (t - i*diff) * (path.curve.point_count - 1)
				if i_f >= 1:
					hand_spawners[i].reparent(self)
				hand_spawners[i].position = path.position + path.curve.samplef(i_f)
				hand_spawners[i].get_node("Sprite2D").visible = true
			if t >= 1+diff:
				start_game()
				get_viewport().get_camera_2d().apply_shake(1)
				stage = Stage.PLAYING
	if not big_fella_head_ready:
		var all_ready = true
		for fella in big_fella:
			fella.motion_offset.y -= delta * 20 * anim_speed
			if fella.motion_offset.y <= 0:
				fella.motion_offset.y = 0
			else:
				all_ready = false
		if all_ready:
			big_fella_head_ready = true

func _input(event):
	if event.is_action_pressed("menu"):
		pause()

func quit():
	get_tree().quit()

func pause():
	if stage != Stage.MENU:
		get_tree().paused = true
		paused.emit()

func unpause():
	get_tree().paused = false

