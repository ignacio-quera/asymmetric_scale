extends StaticBody2D


func place_at(pos):
	position = pos


func _on_despawn_timer_timeout():
	queue_free()


func _on_ghostify_timer_timeout():
	$CollisionShape2D.disabled = true
