extends Node

const Player := preload("res://player.gd")
const Hand := preload("res://hand.gd")

@export var move_curve: Curve

var wait_time: float = 3
var queue_wait: Array[float] = [0, 0]

var moving_from: Vector2
var moving_to: Vector2
var moving_time: float
var move_delay: float

var swipe_next := false
var swipe_delay: float
var swipe_dir: Vector2
var hold_mouse := false

var first_frame := true
var cur_hand := 0
var difficulty: float = 1

var rng := RandomNumberGenerator.new()

const ATTACK_DIRS: Array[Vector2] = [
	Vector2(50, 0),  # Swipe
	Vector2(-50, 0), # Claw
	Vector2(0, 0),   # Fist
	Vector2(0, 50),  # Flick
	Vector2(0, -50), # Swab
]
const ATTACK_WEIGHTS: Array[float] = [1, 1, 1, 0.7, 0.2]

func _ready():
	pass

func randw(seq) -> int:
	var n := len(seq)
	var wt := 0.0
	for w in seq:
		wt += w
	var r := rng.randf() * wt
	var wa := 0.0
	for i in range(n):
		wa += seq[i]
		if r <= wa:
			return i
	return n-1

func attack_dir(atk: Hand.Action) -> Vector2:
	var dir = ATTACK_DIRS[atk]
	if cur_hand == 1:
		dir.x *= -1
	return dir

func choose_player(scr: Array[Vector2], players: Array[Player]) -> Player:
	var weights: Array[float] = []
	for player in players:
		weights.append(3 if player.carrying.get_ref() else 1)
	return players[randw(weights)]

func choose_target(scr: Array[Vector2], players: Array[Player]):
	if not players:
		moving_to = moving_from
		return
	var player := choose_player(scr, players)
	cur_hand = (cur_hand + 1) % 2
	if queue_wait[cur_hand] > 0:
		wait_time = queue_wait[cur_hand]
		queue_wait[cur_hand] = 0
		move_delay = 0
		return
	var atk: Hand.Action = randw(ATTACK_WEIGHTS) as Hand.Action
	moving_time = 0
	move_delay = 1 * difficulty
	swipe_delay = 0.4 * difficulty if atk == Hand.Action.FIST else 0.7 * difficulty
	var pos := player.position
	var predict_delay := move_delay + swipe_delay
	if atk == Hand.Action.FLICK:
		pos.y -= 50
		predict_delay += 0.5
	else:
		predict_delay += 2
	var predict_dir := player.last_vel * predict_delay
	if predict_dir.length() > 1:
		const MAX_PREDICT: float = 60
		predict_dir = predict_dir.normalized() * smoothstep(0, MAX_PREDICT, predict_dir.length()) * MAX_PREDICT
	pos += predict_dir
	pos = pos.clamp(scr[0]+Vector2.ONE*16, scr[1]-Vector2.ONE*16)
	moving_to = pos
	swipe_next = true
	swipe_dir = attack_dir(atk)
	queue_wait[cur_hand] = 1

func _run(scr: Array[Vector2], delta: float, players: Array[Player]) -> Dictionary:
	if first_frame:
		moving_to = lerp(scr[0], scr[1], 0.5)
		first_frame = false
	var pos := Vector2.ZERO
	var want := [false, false]
	
	if hold_mouse:
		want[cur_hand] = true
	
	for i in 2:
		queue_wait[i] = max(0, queue_wait[i] - delta)
	wait_time -= delta
	if wait_time > 0:
		pos = moving_to
	else:
		wait_time = 0
		moving_time += delta
		if moving_time >= move_delay:
			# Next step
			pos = moving_to
			moving_from = moving_to
			hold_mouse = false
			if swipe_next:
				swipe_next = false
				hold_mouse = true
				moving_to = moving_from + swipe_dir
				moving_time = 0
				move_delay = swipe_delay
			else:
				choose_target(scr, players)
		else:
			pos = lerp(moving_from, moving_to, move_curve.sample(moving_time / move_delay))
	return { pos = pos, want_l = want[0], want_r = want[1] }
