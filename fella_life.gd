extends TextureRect


const ALIVE := preload("res://assets/images/bigfellasprites/icon_health.png")
const DEAD := preload("res://assets/images/bigfellasprites/icon_health_lost.png")


func _ready():
	_set_alive(true)


func _set_alive(alive):
	texture = ALIVE if alive else DEAD
