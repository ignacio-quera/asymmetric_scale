extends Label


@export var delay: float


var time := 0.0


func _ready():
	visible = false

func _process(delta):
	time += delta
	visible = (time >= delay)
