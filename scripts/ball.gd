extends RigidBody3D

@export var rolling_force: float = 40.0
@export var jump_impulse: float = 100.0
@onready var spawn_point: Node3D = %SpawnPoint
@onready var floor_check: RayCast3D = $FloorCheck
@onready var camera: Node3D = $CameraRig
@onready var enemy: Node3D = $"../Enemy"  # Gán node kẻ thù

var _spawn_transform: Transform3D

func _ready():
	camera.top_level = true
	floor_check.top_level = true
	
	if spawn_point != null:
		_spawn_transform = spawn_point.global_transform
	else:
		_spawn_transform = global_transform

func _physics_process(delta):
	camera.global_transform.origin = global_transform.origin
	floor_check.global_transform.origin = global_transform.origin
	
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

	if is_on_floor:
		_spawn_transform = global_transform

func respawn():
	freeze = true

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	global_transform = _spawn_transform

	$CameraRig.global_transform.origin = global_transform.origin
	$FloorCheck.global_transform.origin = global_transform.origin

	await get_tree().process_frame
	freeze = false
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		var repel_direction = (global_transform.origin - body.global_transform.origin).normalized()  # Hướng từ người chơi ra kẻ thù
		var repel_force = 800.0  
		apply_central_impulse(repel_direction * repel_force) 
	
	
	if body.is_in_group("boss"):
		var repel_direction = (global_transform.origin - body.global_transform.origin).normalized()  # Hướng từ người chơi ra kẻ thù
		var repel_force = 2000.0 
		apply_central_impulse(repel_direction * repel_force) 

	# Add this new condition for weak enemies
	if body.is_in_group("weak_enemy"):
		var repel_direction = (global_transform.origin - body.global_transform.origin).normalized()
		var repel_force = 600.0  # No knockback for weak enemies
		apply_central_impulse(repel_direction * repel_force)
