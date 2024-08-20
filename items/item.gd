extends StaticBody2D

signal picked_signal
signal deposited

var t:float = 0
var type:String
var shape:String
var picked_by: WeakRef = WeakRef.new()
var crankable:bool = false
var interactable = true
var last_entered

var compatible_slot: String

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
	if crankable:
		global_position = $"../CrankSlot".global_position
	if crankable and interactable:
		if Input.is_action_just_pressed("action%s" % last_entered) or Input.is_action_just_pressed("up%s" % last_entered):
			rotation += 15 * delta
			$"..".crank()
		

func player_interact(player_area):
	if not picked_by.get_ref() and not crankable:
		player_area.encumber(self)
		$CollisionShape2D.disabled = true
		z_index = 1
	elif crankable:
		pass
	else:
		picked_by.get_ref().unencumber()
		$CollisionShape2D.disabled = false
		z_index = 0




func _on_interactive_area_area_entered(area):
	var slot = area
	if crankable and area.get_parent().is_in_group("littleguy"):
		last_entered = area.get_parent().player_id
		interactable = true
	if "Slot" in slot.name:
		if "Crank" in name and "Crank" in slot.name:
			crankable = true
			if picked_by.get_ref():
				picked_by.get_ref().unencumber()
			global_position = slot.global_position
			$Shadow.hide()
			if $"SpritePath/SpritePathFollow/".get_child_count() != 0:
				$SpritePath/SpritePathFollow/Sprite2D.z_index = 6
				$SpritePath/SpritePathFollow.progress_ratio = 0
				$SpritePath/SpritePathFollow/Sprite2D.reparent(self)
			return
		if "Magic" in name:
			if slot.shape == shape:
				if picked_by.get_ref():
					picked_by.get_ref().unencumber()
				position = slot.position
				$Shadow.hide()
				$"..".deposit_item()


func _on_interactive_area_area_exited(area):
	interactable = false
	pass


func _on_area_2d_body_entered(body):
	print("test")
