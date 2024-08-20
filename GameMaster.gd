extends Node

@export var player_default_lives := 5
@export var bigfella_default_lives := 1

@export var bigfella_sprites: Array[Sprite2D]
@export var postgame_scene: PackedScene
@export var player_scene: PackedScene
@export var player_spawner: Path2D
@export var player_hud_scene: PackedScene
@export var player_huds: BoxContainer
@export var fella_hud: BoxContainer
@export var hud_panel: PanelContainer
@export var player_colors: Array[Color]

const Player := preload("res://player.gd")

const FINISH_ANIM_TIME: float = 5
const RESPAWN_TIME: float = 5

var player_count: int
var playing: bool = true
var time: float = 0

var bigfella_health: int
var players: Array[WeakRef] = []
var lives_left: Array[int] = []

func player_color(num: int):
	return player_colors[num % len(player_colors)]

# Called when the node enters the scene tree for the first time.
func _ready():
	bigfella_health = bigfella_default_lives

func spawn_player(player_num):
	var player = player_scene.instantiate()
	var spawn_pos = player_spawner.position + player_spawner.curve.sample_baked(player_num * 20)
	get_parent().add_child(player)
	var player_num_name = player_num+1
	player.name = "Player%s" % player_num_name
	player.start(spawn_pos, player_num, player_color(player_num))
	players[player_num] = weakref(player)

func new_player(player_num):
	players.append(WeakRef.new())
	lives_left.append(player_default_lives)
	spawn_player(player_num)
	
	var hud = player_hud_scene.instantiate()
	hud.modulate = player_color(player_num)
	player_huds.add_child(hud)

func spawn_players(pnum):
	player_count = pnum
	for player in player_count:
		new_player(player)
	update_lives_indicator()

func start_game():
	for i in bigfella_health:
		fella_hud.add_child(preload("res://fella_life.tscn").instantiate())
	hud_panel.visible = true
	$task_controller.new_task()

func finish_game():
	print("finished game")
	var postgame = postgame_scene.instantiate()
	postgame.bigfella_wins = (bigfella_health > 0)
	get_tree().root.get_child(0).queue_free()
	get_tree().root.add_child(postgame)
	get_tree().current_scene = postgame


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if playing:
		pass
	else:
		var bigfella_won = (bigfella_health > 0)
		if bigfella_won:
			if time >= 1:
				$"../ParallaxBackground/FellaAnim".play("laugh")
		else:
			for player in players:
				if player.get_ref():
					player.get_ref()._celebrate()
			get_viewport().get_camera_2d().apply_shake(0.6)
			for sprite in bigfella_sprites:
				sprite.position.y += delta * 10
		var t = (time - FINISH_ANIM_TIME/2) / (FINISH_ANIM_TIME/2)
		$CanvasLayer/FadeToBlack.visible = true
		$CanvasLayer/FadeToBlack.color.a = clamp(t, 0, 1)
		if time >= FINISH_ANIM_TIME:
			# Finish game
			finish_game()


func _hurt_bigfella(amount: int = 1):
	if not playing:
		return
	bigfella_health -= amount
	get_viewport().get_camera_2d().apply_shake(1)
	for i in fella_hud.get_child_count():
		fella_hud.get_child(i)._set_alive(i < bigfella_health)
	if bigfella_health <= 0:
		playing = false
		time = 0
	else:
		$task_controller.new_task()

func update_lives_indicator():
	for i in player_count:
		player_huds.get_child(i)._update_lives_left(lives_left[i])

func _player_died(player_num: int):
	lives_left[player_num] -= 1
	update_lives_indicator()
	if playing and lives_left.all(func(n): return n <= 0):
		# Big fella won
		playing = false
		time = 0
	kill_sfx()
	if lives_left[player_num] > 0:
		await get_tree().create_timer(RESPAWN_TIME).timeout
		spawn_player(player_num)

func kill_sfx():
	get_viewport().get_camera_2d().apply_shake(0.5)
	# await get_tree().create_timer(0.05).timeout
	get_tree().paused = true
	await get_tree().create_timer(0.15).timeout
	get_tree().paused = false
