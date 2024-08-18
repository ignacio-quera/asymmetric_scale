extends Camera2D

@export var decay := 0.8 #How quickly shaking will stop [0,1].
@export var offset_ampl: Vector2 #Maximum displacement in pixels.
@export var roll_ampl := 0.0 #Maximum rotation in radians (use sparingly).
@export var noise: FastNoiseLite #The source of random values.
@export var enable_shake := false

var noise_y = 0 #Value used to move through the noise

var trauma := 0.0 #Current shake strength
var trauma_pwr := 3 #Trauma exponent. Use [2,3]

func _ready():
	pass

func _process(delta):
	trauma = max(trauma - decay * delta, 0)
	if enable_shake:
		var amt = trauma ** trauma_pwr
		noise_y += delta * 60
		rotation = roll_ampl * amt * noise.get_noise_2d(1234, noise_y)
		offset.x = offset_ampl.x * amt * noise.get_noise_2d(2345, noise_y)
		offset.y = offset_ampl.y * amt * noise.get_noise_2d(3456, noise_y)

# Llamar a esta funcion para agregar shake a la camara
func apply_shake(shake: float):
	print("applying shake ", shake)
	trauma = max(trauma, shake)
