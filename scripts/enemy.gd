extends CharacterBody3D

@export var chase_speed: float = 5.0
@export var repel_force: float = 600.0
@export var floor_snap: float = 0.3
@export var fall_timeout_sec: float = 5.0        # <— thời gian chờ ngoài sàn

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var player: Node3D = $"../Ball"
@onready var chase_area: Area3D = $Area3D2
@onready var collision_area: Area3D = $ColliArea3D
@onready var floor_check: RayCast3D = $FloorCheck

# --- NEW: lưu vị trí spawn + timer rơi ---
var _spawn_transform: Transform3D
var _was_on_floor := false
@onready var _fall_timer: Timer = Timer.new()

var _is_chasing := false

func _ready():
	add_to_group("weak_enemy")
	chase_area.body_entered.connect(_on_area_entered)
	chase_area.body_exited.connect(_on_area_exited)
	collision_area.body_entered.connect(_on_collision_with_body)
	floor_snap_length = floor_snap

	# --- NEW: setup spawn & timer ---
	_spawn_transform = global_transform
	_was_on_floor = is_on_floor()

	_fall_timer.one_shot = true
	_fall_timer.wait_time = fall_timeout_sec
	add_child(_fall_timer)
	_fall_timer.timeout.connect(_on_fall_timeout)

func _physics_process(delta):
	# --- Gravity / bám sàn ---
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -1.0

	# --- Theo dõi trạng thái sàn để start/stop timer ---
	var on_floor := is_on_floor()
	if on_floor:
		if !_fall_timer.is_stopped():
			_fall_timer.stop()
	else:
		# vừa rời sàn thì bắt đầu đếm 5s
		if _was_on_floor and _fall_timer.is_stopped():
			_fall_timer.start()

	_was_on_floor = on_floor

	# --- Di chuyển ngang (XZ) ---
	if _is_chasing and is_instance_valid(player):
		var dir := (player.global_transform.origin - global_transform.origin)
		dir.y = 0.0
		dir = dir.normalized()

		velocity.x = dir.x * chase_speed
		velocity.z = dir.z * chase_speed

	else:
		velocity.x = move_toward(velocity.x, 0.0, chase_speed * 4.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, chase_speed * 4.0 * delta)


	move_and_slide()

func _on_area_entered(body: Node) -> void:
	if body == player:
		_is_chasing = true

func _on_area_exited(body: Node) -> void:
	if body == player:
		_is_chasing = false

func _on_collision_with_body(body: Node) -> void:
	if body == player:
		var dir := (global_transform.origin - player.global_transform.origin)
		dir.y = 0.0
		dir = dir.normalized()
		velocity.x -= dir.x * repel_force
		velocity.z -= dir.z * repel_force
		if body.has_method("apply_central_impulse"):
			body.apply_central_impulse(dir * repel_force)

# --- NEW: Hết 5s vẫn chưa chạm sàn thì reset ---
func _on_fall_timeout() -> void:
	if not is_on_floor():
		_reset_to_spawn()

func _reset_to_spawn() -> void:
	global_transform = _spawn_transform
	velocity = Vector3.ZERO
	_is_chasing = false
