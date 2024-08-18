extends StaticBody2D

signal picked_signal
signal deposited

var picked = false
var t:float = 0
var type:String
var shape:String
var picked_by
# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_size = get_viewport_rect().size
	show()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	if picked:
		global_position = Vector2(picked_by.position.x, picked_by.position.y-10)
	else:
		$SpritePath/SpritePathFollow.progress = t * 10

func player_interact(player_area):
	if not picked:
		picked = true
		picked_by = player_area
		$CollisionShape2D.disabled = true
		picked_by.encumber()
		z_index = 1
	else:
		picked = false
		$CollisionShape2D.disabled = false
		picked_by.unencumber()
		picked_by = null
		z_index = 0


func _on_interactive_area_area_entered(area):
	var slot = area
	if "Slot" in slot.name:
		if slot.shape == shape:
			picked = false
			if picked_by:
				picked_by.unencumber()
				picked_by = null
			position = slot.position
			$Shadow.hide()
			$SpritePath/SpritePathFollow.progress_ratio = 0
			$SpritePath/SpritePathFollow/Sprite2D.reparent(self)
			$".."
