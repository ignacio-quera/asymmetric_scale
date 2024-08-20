extends Node

const Hand = preload("res://hand.gd")
const Player = preload("res://player.gd")

const HOVER_GRADIENT = [preload("res://assets/gradients/lefthover.tres"), preload("res://assets/gradients/righthover.tres")]
var SINGLE_GRADIENT = []

const ANCHOR_READY = preload("res://assets/images/bigfellasprites/anchor_ready.png")
const ANCHOR_WAIT = preload("res://assets/images/bigfellasprites/anchor_cooldown.png")

const FIST_DISTANCE: float = 30
const DELAY: float = 1
const COOLDOWN_DURATION: float = 0.5
const SWAB_COOLDOWN: float = 6

const HandAi := preload("res://hand_ai.gd")
enum Dir {LEFT, RIGHT}

var choosing: bool = false
var choose_dir: Dir = Dir.LEFT

var swab_cooldown: float = 0

var use_ai: bool

func _init():
	for grad in HOVER_GRADIENT:
		var newgrad = grad.duplicate()
		newgrad.remove_point(1)
		SINGLE_GRADIENT.append(newgrad)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _enable_ai(enable: bool, diff: float):
	use_ai = enable
	$HandAI.difficulty = diff
	$HandAI.wait_time *= diff
	$AiHandSprite.visible = enable


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var scr = get_viewport().get_visible_rect().size
	var pos: Vector2
	var want_l: bool
	var want_r: bool
	if use_ai:
		var area: Array[Vector2] = [Vector2(0, 90), Vector2(480, 270)]
		var players: Array[Player] = []
		for player in get_tree().get_nodes_in_group("littleguy"):
			players.append(player)
		var ai_choice = $HandAI._run(area, delta, players)
		pos = ai_choice.pos
		want_l = ai_choice.want_l
		want_r = ai_choice.want_r
	else:
		pos = get_viewport().get_mouse_position()
		want_l = Input.is_action_pressed("drag_left")
		want_r = Input.is_action_pressed("drag_right")

	var want_choose = want_l or want_r
	if want_choose and not choosing:
		$Anchor.position = pos
		if want_l:
			choose_dir = Dir.LEFT
		else:
			choose_dir = Dir.RIGHT
	var anchor = $Anchor.position
	var action = null
	var d = pos - anchor
	if d.length() < FIST_DISTANCE:
		action = Hand.Action.FIST
	elif abs(d.x) > abs(d.y):
		if (d.x < 0) == (choose_dir == Dir.RIGHT):
			action = Hand.Action.SWIPE
		else:
			action = Hand.Action.CLAW
	else:
		if d.y < 0:
			action = Hand.Action.SWAB
		else:
			action = Hand.Action.FLICK
	var hand: Hand = ($HandL if choose_dir == Dir.LEFT else $HandR)
	var ready_to_attack = hand.ready_to_attack()
	if action == Hand.Action.SWAB and swab_cooldown > 0:
		ready_to_attack = false
	if not want_choose and choosing and ready_to_attack:
		hand.do_action(action, anchor)
		if action == Hand.Action.SWAB:
			swab_cooldown = SWAB_COOLDOWN
	choosing = want_choose
	$Anchor.visible = choosing
	$Anchor.texture = (ANCHOR_READY if ready_to_attack else ANCHOR_WAIT)
	$ActionPreview.visible = false
	$FlickPreview.visible = false
	var icon = null
	if choosing and ready_to_attack:
		$ActionPreview.clear_points()
		$ActionPreview.width = 2*hand.action_radius(action)
		$ActionPreview.gradient = HOVER_GRADIENT[choose_dir]
		match action:
			Hand.Action.FIST:
				icon = preload("res://assets/images/bigfellasprites/icon_center.png")
				$ActionPreview.visible = true
				$ActionPreview.add_point(anchor)
				$ActionPreview.add_point(anchor+Vector2.UP)
				$ActionPreview.gradient = SINGLE_GRADIENT[choose_dir]
				$ActionPreview.width = 2*FIST_DISTANCE
			Hand.Action.SWIPE:
				$ActionPreview.visible = true
				$ActionPreview.add_point(Vector2(0, anchor.y))
				$ActionPreview.add_point(Vector2(scr.x, anchor.y))
				if choose_dir == Dir.RIGHT:
					icon = preload("res://assets/images/bigfellasprites/icon_forward_l.png")
				else:
					icon = preload("res://assets/images/bigfellasprites/icon_forward_r.png")
			Hand.Action.CLAW:
				$ActionPreview.visible = true
				$ActionPreview.add_point(Vector2(scr.x, anchor.y))
				$ActionPreview.add_point(Vector2(0, anchor.y))
				if choose_dir == Dir.RIGHT:
					icon = preload("res://assets/images/bigfellasprites/icon_backwards_l.png")
				else:
					icon = preload("res://assets/images/bigfellasprites/icon_backwards_r.png")
			Hand.Action.FLICK:
				$FlickPreview.visible = true
				$FlickPreview.texture.gradient = HOVER_GRADIENT[choose_dir]
				$FlickPreview.position = anchor
				icon = preload("res://assets/images/bigfellasprites/icon_down.png")
			Hand.Action.SWAB:
				$ActionPreview.visible = true
				$ActionPreview.add_point(Vector2(anchor.x, scr.y))
				$ActionPreview.add_point(Vector2(anchor.x, 0))
				icon = preload("res://assets/images/bigfellasprites/icon_up.png")
	if use_ai:
		if icon == null:
			$AiHandSprite.texture = preload("res://assets/images/bigfellasprites/icon_ai.png")
			$AiHandSprite.centered = false
		else:
			$AiHandSprite.texture = icon
			$AiHandSprite.centered = true
		$AiHandSprite.position = pos
	else:
		if icon == null:
			Input.set_custom_mouse_cursor(null)
		else:
			Input.set_custom_mouse_cursor(icon, 0, icon.get_size()/2)
	swab_cooldown = max(0, swab_cooldown - delta)
