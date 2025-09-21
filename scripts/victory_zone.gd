extends Area3D

@export var next_level: PackedScene
@export var is_tutorial: bool = false
@onready var Level = $".."

func _on_body_entered(body: Node):
	if body.name != "Ball":
		return

	Level.call_deferred("on_round_win")
