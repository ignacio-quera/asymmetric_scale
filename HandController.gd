extends Node


var RECORD_DISTANCE: float = 10
var MAX_RECORD_DIST: int = 200
var MAX_RECORD_DURATION: float = 1
var DELAY: float = 1
var COOLDOWN_DURATION: float = 0.5

@export var action_button: String = "drag_left"

enum State {IDLE, RECORDING, WAITING, REPLAYING, COOLDOWN}

var state: State = State.IDLE
var time: float = 0
var follow_curve: Curve2D = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	match state:
		State.IDLE:
			if Input.is_action_pressed(action_button):
				state = State.RECORDING
				time = 0
		State.RECORDING:
			var pos = get_viewport().get_mouse_position()
			var n = $Line2D.get_point_count()
			if n > 1:
				$Line2D.remove_point(n-1)
			n = $Line2D.get_point_count()
			if n > 0 and ($Line2D.get_point_position(n-1) - pos).length() >= RECORD_DISTANCE:
				$Line2D.add_point(pos)
			$Line2D.add_point(pos)
			var total_dist = 0
			for i in range(1, $Line2D.get_point_count()):
				var a = $Line2D.get_point_position(i-1)
				var b = $Line2D.get_point_position(i)
				total_dist += (b - a).length()
			if n >= 2 and (time >= MAX_RECORD_DURATION
					or total_dist >= MAX_RECORD_DIST
					or not Input.is_action_pressed(action_button)
					):
				state = State.WAITING
				time -= MAX_RECORD_DURATION
				follow_curve = Curve2D.new()
				follow_curve.add_point($Hand.position, Vector2.ZERO, $Line2D.get_point_position(0) - $Hand.position)
				follow_curve.add_point($Line2D.get_point_position(0), Vector2.UP*100)
		State.WAITING:
			if time >= DELAY:
				state = State.REPLAYING
				time = 0
				follow_curve = Curve2D.new()
				var n = $Line2D.get_point_count()
				for i in range(n):
					var out = Vector2.ZERO
					if i == n-1:
						out = Vector2.UP * 20
					follow_curve.add_point($Line2D.get_point_position(i), Vector2.ZERO, out)
			else:
				var t = time / DELAY
				$Hand.position = follow_curve.samplef(clamp(t, 0, 1))
		State.REPLAYING:
			var t = time * 500
			t = t / follow_curve.get_baked_length()
			if t <= 1:
				var want_n = follow_curve.point_count - floor(t * follow_curve.point_count)
				while want_n < $Line2D.get_point_count():
					$Line2D.remove_point(0)
				var pos = follow_curve.sample_baked(t * follow_curve.get_baked_length())
				$Hand.position = pos
			else:
				#var last = follow_curve.get_point_position(follow_curve.point_count-1)
				#follow_curve = Curve2D.new()
				#follow_curve.add_point(last)
				#follow_curve.add_point(last+Vector2.UP*4)
				$Line2D.clear_points()
				state = State.COOLDOWN
				time = 0
		State.COOLDOWN:
			if time >= COOLDOWN_DURATION:
				state = State.IDLE
				time = 0
			else:
				var t = time / COOLDOWN_DURATION
				$Hand.position = follow_curve.sample(follow_curve.point_count, t)
