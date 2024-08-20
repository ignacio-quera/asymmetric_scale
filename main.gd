extends Node

@export var anim_speed: float = 1
@export var hand_controller_scene: PackedScene
@export var invisible_when_raising: Array
@export var hand_spawners: Array[Node2D]
@export var big_fella: Array[Node2D]

signal paused

enum Stage { RAISING, MENU, LOWERING, SPAWNING, PLAYING }

var stage := Stage.MENU
var time := 0.0
var last_t := 0.0
var big_fella_head_ready := true
var player_count: int
var difficulty: float = 1

var og_camera_offset: float

func new_game(num_of_players: int):
	player_count = num_of_players
	$GameMaster.spawn_players(max(1, player_count - 1))
	$StartMenu.visible = false
	stage = Stage.LOWERING
	$GameMusic.play()
	$MenuMusic.stop()

func reload_menu_music():
	$MenuMusic.play()
	
func reload_game_music():
	$GameMusic.play()

func start_game():
	$Camera2D.offset.y = 0
	# $ParallaxBackground/Background_Sky.motion_scale = Vector2.ONE * 0.1
	# $ParallaxBackground/Stage.motion_scale = Vector2.ONE
	for hand in hand_spawners:
		remove_child(hand)
	var hand_controller = hand_controller_scene.instantiate()
	hand_controller._enable_ai(player_count == 1, difficulty)
	add_child(hand_controller)
	$GameMaster.process_mode = Node.PROCESS_MODE_INHERIT
	$GameMaster.start_game()
	$ParallaxBackground/FellaAnim.play("bobbing")

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

func _on_set_settings():
	$Settings.visible = true
	$Settings/CanvasLayer.visible = true
	pass # Replace with function body.


func _on_settings_set_lives():
	$GameMaster.bigfella_health = $Settings/FellaLives.value
	$GameMaster.player_default_lives = $Settings/GuyLives.value
	$Settings.visible = false
	$Settings/CanvasLayer.visible = false
	match $Settings/Difficulty.selected:
		0:
			difficulty = 1.5
		1:
			difficulty = 1
		2:
			difficulty = 0.5
	pass # Replace with function body.
