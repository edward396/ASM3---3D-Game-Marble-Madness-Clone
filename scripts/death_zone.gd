extends Area3D

func _on_body_entered(body):
	if body.name == "Ball" and body.has_method("respawn"):
		#get_tree().reload_current_scene()
		body.respawn()
