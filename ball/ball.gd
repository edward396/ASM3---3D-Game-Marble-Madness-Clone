extends RigidBody3D

@export var rolling_force: float = 40.0
@export var jump_impulse: float = 200.0
@export_node_path("Node3D") var spawn_point_path

var _spawn_transform: Transform3D

func _ready():
	$CameraRig.top_level = true
	$FloorCheck.top_level = true

	if spawn_point_path != null and has_node(spawn_point_path):
		_spawn_transform = get_node(spawn_point_path).global_transform
	else:
		_spawn_transform = global_transform

func _physics_process(delta):
	var old_camera_pos = $CameraRig.global_transform.origin
	var ball_pos = global_transform.origin
	var new_camera_pos = lerp(old_camera_pos, ball_pos, 0.01)

	$CameraRig.global_transform.origin = global_transform.origin

	$FloorCheck.global_transform.origin = global_transform.origin
	
	if Input.is_action_pressed("forward"):
		angular_velocity.x -= rolling_force * delta
	elif Input.is_action_pressed("back"):
		angular_velocity.x += rolling_force * delta
	if Input.is_action_pressed("left"):
		angular_velocity.z += rolling_force * delta
	elif Input.is_action_pressed("right"):
		angular_velocity.z -= rolling_force * delta

	var is_on_floor = $FloorCheck.is_colliding()
	if Input.is_action_pressed("jump") and is_on_floor:
		apply_central_impulse(Vector3.UP * jump_impulse)

func respawn():
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	sleeping = true
	global_transform = _spawn_transform
	await get_tree().process_frame
	sleeping = false