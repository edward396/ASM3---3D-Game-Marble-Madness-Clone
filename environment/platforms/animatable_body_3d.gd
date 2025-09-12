extends AnimatableBody3D

@export var move_distance: Vector3 = Vector3(5, 0, 0)  # Movement offset
@export var move_duration: float = 4.0  # Time for one direction

var start_position: Vector3
var tween: Tween

func _ready():
	start_position = global_position  # Remember where you placed it
	create_movement()

func create_movement():
	tween = create_tween()
	tween.set_loops()
	
	var end_position = start_position + move_distance
	tween.tween_property(self, "global_position", end_position, move_duration)
	tween.tween_property(self, "global_position", start_position, move_duration)
