extends Area3D

@export var safe_position: Vector3

func _ready():
	body_entered.connect(_on_player_fell)

func _on_player_fell(body: Node3D):
	if body.name == "Ball":
		body.global_position = safe_position
		# Use linear_velocity for RigidBody3D
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
