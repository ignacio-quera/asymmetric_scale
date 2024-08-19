extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func player_interact_enter(player_area):
	print("test_multi")
	#if not $"..".picked_by.get_ref():
		#$"..".holder = self
		#player_area.encumber($"..")
		#$CollisionShape2D.disabled = true
		#z_index = 1
	#else:
		#$"..".picked_by.get_ref().unencumber()
		#$CollisionShape2D.disabled = false
		#z_index = 0
