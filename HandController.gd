extends Node

const Hand = preload("res://hand.gd")

const HOVER_GRADIENT = [preload("res://assets/gradients/lefthover.tres"), preload("res://assets/gradients/righthover.tres")]
var SINGLE_GRADIENT = HOVER_GRADIENT.duplicate()

const ANCHOR_READY = preload("res://assets/images/bigfellasprites/anchor_ready.png")
const ANCHOR_WAIT = preload("res://assets/images/bigfellasprites/anchor_cooldown.png")

const FIST_DISTANCE: float = 30
const DELAY: float = 1
const COOLDOWN_DURATION: float = 0.5

enum Dir {LEFT, RIGHT}

var choosing: bool = false
var choose_dir: Dir = Dir.LEFT

func _init():
	for grad in SINGLE_GRADIENT:
		grad.remove_point(1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var scr = get_viewport().get_visible_rect().size
	var pos = get_viewport().get_mouse_position()
	var want_l = Input.is_action_pressed("drag_left")
	var want_r = Input.is_action_pressed("drag_right")
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
			action = Hand.Action.BACKHAND
	else:
		if d.y < 0:
			action = Hand.Action.PUNCH
		else:
			action = Hand.Action.CLAW
	var hand: Hand = ($HandL if choose_dir == Dir.LEFT else $HandR)
	if not want_choose and choosing and hand.ready_to_attack():
		hand.do_action(action, anchor)
	choosing = want_choose
	$Anchor.visible = choosing
	$Anchor.texture = (ANCHOR_READY if hand.ready_to_attack() else ANCHOR_WAIT)
	$ActionPreview.visible = choosing and hand.ready_to_attack()
	var icon = null
	if choosing:
		$ActionPreview.clear_points()
		$ActionPreview.width = 2*$HandL/CollisionShape2D.shape.radius
		$ActionPreview.gradient = HOVER_GRADIENT[choose_dir]
		match action:
			Hand.Action.FIST:
				icon = preload("res://assets/images/bigfellasprites/icon_fist.png")
				$ActionPreview.add_point(anchor)
				$ActionPreview.add_point(anchor+Vector2.UP)
				$ActionPreview.gradient = SINGLE_GRADIENT[choose_dir]
				$ActionPreview.width = 2*FIST_DISTANCE
			Hand.Action.SWIPE:
				$ActionPreview.add_point(Vector2(0, anchor.y))
				$ActionPreview.add_point(Vector2(scr.x, anchor.y))
				if choose_dir == Dir.RIGHT:
					icon = preload("res://assets/images/bigfellasprites/icon_swipe.png")
				else:
					icon = preload("res://assets/images/bigfellasprites/icon_swipe_r.png")
			Hand.Action.BACKHAND:
				$ActionPreview.add_point(Vector2(scr.x, anchor.y))
				$ActionPreview.add_point(Vector2(0, anchor.y))
				if choose_dir == Dir.RIGHT:
					icon = preload("res://assets/images/bigfellasprites/icon_swipe_r.png")
				else:
					icon = preload("res://assets/images/bigfellasprites/icon_swipe.png")
			Hand.Action.CLAW:
				$ActionPreview.add_point(Vector2(anchor.x, 0))
				$ActionPreview.add_point(Vector2(anchor.x, scr.y))
				icon = preload("res://assets/images/bigfellasprites/icon_claw.png")
			Hand.Action.PUNCH:
				$ActionPreview.add_point(Vector2(anchor.x, scr.y))
				$ActionPreview.add_point(Vector2(anchor.x, 0))
				icon = preload("res://assets/images/bigfellasprites/icon_punch.png")
	if icon == null:
		Input.set_custom_mouse_cursor(null)
	else:
		Input.set_custom_mouse_cursor(icon, 0, icon.get_size()/2)
