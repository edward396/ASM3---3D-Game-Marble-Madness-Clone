extends Area3D

@export_file("*.tscn") var NEXT_LEVEL: String

func _on_body_entered(body):
	if body.name == "Ball" and NEXT_LEVEL != "":
		get_tree().change_scene_to_file(NEXT_LEVEL)
