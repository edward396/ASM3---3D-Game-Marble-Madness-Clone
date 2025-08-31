extends RigidBody3D

@export var rolling_force: float = 40.0
@export var jump_impulse: float = 200.0
@onready var spawn_point: Node3D = %SpawnPoint
@onready var floor_check: RayCast3D = $FloorCheck
@onready var camera: Node3D = $CameraRig

var _spawn_transform: Transform3D

func _ready():
	camera.top_level = true
	floor_check.top_level = true
	
	if spawn_point != null:
		_spawn_transform = spawn_point.global_transform
	else:
		_spawn_transform = global_transform


func _physics_process(delta):
	#var old_camera_pos = $CameraRig.global_transform.origin
	#var ball_pos = global_transform.origin
	#var new_camera_pos = lerp(old_camera_pos, ball_pos, 0.01)
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

	var is_on_floor = floor_check.is_colliding()
	if Input.is_action_pressed("jump") and is_on_floor:
		apply_central_impulse(Vector3.UP * jump_impulse)

	#update the safest respawn point
	if is_on_floor:
		_spawn_transform = global_transform


func respawn():
	freeze = true

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	global_transform = _spawn_transform

	# đồng bộ camera/floor check ngay lập tức (tránh lerp kéo ngược)
	$CameraRig.global_transform.origin = global_transform.origin
	$FloorCheck.global_transform.origin = global_transform.origin

	#wait 1 physics frame
	await get_tree().process_frame
	freeze = false
