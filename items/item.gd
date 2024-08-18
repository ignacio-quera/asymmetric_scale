extends StaticBody2D

signal picked_signal
signal deposited

var t:float = 0
var type:String
var shape:String
var picked_by: WeakRef = WeakRef.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_size = get_viewport_rect().size
	show()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	if picked_by.get_ref():
		global_position = Vector2(picked_by.get_ref().position.x, picked_by.get_ref().position.y-10)
	else:
		$SpritePath/SpritePathFollow.progress = t * 10

func player_interact(player_area):
	if not picked_by.get_ref():
		player_area.encumber(self)
		$CollisionShape2D.disabled = true
		z_index = 1
	else:
		picked_by.get_ref().unencumber()
		$CollisionShape2D.disabled = false
		z_index = 0


func _on_interactive_area_area_entered(area):
	var slot = area
	if "Slot" in slot.name:
		if slot.shape == shape:
			if picked_by.get_ref():
				picked_by.get_ref().unencumber()
			position = slot.position
			$Shadow.hide()
			# $SpritePath/SpritePathFollow.progress_ratio = 0
			# $SpritePath/SpritePathFollow/Sprite2D.reparent(self)
			$"..".deposit_item()
