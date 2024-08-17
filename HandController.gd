extends Node

const Hand = preload("res://hand.gd")


var RECORD_DISTANCE: float = 10
var MAX_RECORD_DIST: int = 200
var MAX_RECORD_DURATION: float = 0.5
var DELAY: float = 1
var COOLDOWN_DURATION: float = 0.5

enum Dir {LEFT, RIGHT}

var choosing: bool = false
var choose_dir: Dir = Dir.LEFT

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pos = get_viewport().get_mouse_position()
	var want_l = Input.is_action_pressed("drag_left") and $HandL.ready_to_attack()
	var want_r = Input.is_action_pressed("drag_right") and $HandR.ready_to_attack()
	var want_choose = want_l or want_r
	if want_choose and not choosing:
		$Anchor.position = pos
		if want_l:
			choose_dir = Dir.LEFT
		else:
			choose_dir = Dir.RIGHT
	var action = null
	var d = pos - $Anchor.position
	if d.length() < 30:
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
	if not want_choose and choosing:
		var hand: Hand = ($HandL if choose_dir == Dir.LEFT else $HandR)
		hand.do_action(action, $Anchor.position)
	choosing = want_choose
	$Anchor.visible = choosing
	var icon = null
	if choosing:
		match action:
			Hand.Action.FIST:
				icon = preload("res://assets/images/bigfellasprites/icon_fist.png")
			Hand.Action.SWIPE:
				if choose_dir == Dir.RIGHT:
					icon = preload("res://assets/images/bigfellasprites/icon_swipe.png")
				else:
					icon = preload("res://assets/images/bigfellasprites/icon_swipe_r.png")
			Hand.Action.BACKHAND:
				if choose_dir == Dir.RIGHT:
					icon = preload("res://assets/images/bigfellasprites/icon_swipe_r.png")
				else:
					icon = preload("res://assets/images/bigfellasprites/icon_swipe.png")
			Hand.Action.CLAW:
				icon = preload("res://assets/images/bigfellasprites/icon_claw.png")
			Hand.Action.PUNCH:
				icon = preload("res://assets/images/bigfellasprites/icon_punch.png")
	if icon == null:
		Input.set_custom_mouse_cursor(null)
	else:
		Input.set_custom_mouse_cursor(icon, 0, icon.get_size()/2)
