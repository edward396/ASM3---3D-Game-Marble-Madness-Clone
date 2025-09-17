extends Area3D

@export var next_level: PackedScene
@onready var Level = $".."

func _on_body_entered(body: Node):
	if body.name != "Ball" or next_level == null:
		return

	var tree := get_tree()
	Level.call_deferred("on_round_win")
	tree.call_deferred("change_scene_to_packed", next_level)
