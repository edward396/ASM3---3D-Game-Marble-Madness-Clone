extends RigidBody3D

@export var rolling_force: float = 40.0
@export var jump_impulse: float = 200.0
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

	if enemy != null:
		if is_colliding_with_enemy():
			apply_repel_force()

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
	
func is_colliding_with_enemy() -> bool:
	return global_transform.origin.distance_to(enemy.global_transform.origin) < 2.0 

func apply_repel_force():
	var repel_direction = (global_transform.origin - enemy.global_transform.origin).normalized()  # Hướng từ người chơi ra kẻ thù
	var repel_force = 50.0  # Độ mạnh của lực đẩy
	apply_central_impulse(repel_direction * repel_force)  
