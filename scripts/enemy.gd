extends CharacterBody3D

@export var chase_speed: float = 2
@onready var player: Node3D = $"../Ball"
@onready var chase_area: Area3D = $Area3D2
@onready var collision_area: Area3D = $ColliArea3D
@onready var model: Node3D = $godot_plush_model	# Reference to the visual model

var is_chasing: bool = false
var target_position: Vector3

func _ready():
	chase_area.body_entered.connect(_on_area_entered)
	chase_area.body_exited.connect(_on_area_exited)
	collision_area.body_entered.connect(_on_collision_with_player)

func _physics_process(delta):
	if is_chasing:
		target_position = player.global_transform.origin
		var direction = (target_position - global_transform.origin).normalized()
		
		# Rotate model to face the player
		if direction.length() > 0.1:
			var target_rotation = atan2(direction.x, direction.z)
			model.rotation.y = lerp_angle(model.rotation.y, target_rotation, delta * 5.0)
		
		velocity = direction * chase_speed 
		move_and_slide()

func _on_area_entered(body: Node):
	if body == player:
		start_chasing()

func _on_area_exited(body: Node):
	if body == player:
		stop_chasing()

func _on_collision_with_player(body: Node):
	if body == player:
		apply_repel_force(body)

func start_chasing():
	is_chasing = true
	target_position = player.global_transform.origin 

func stop_chasing():
	is_chasing = false
	target_position = Vector3.ZERO 
 
func apply_repel_force(player: Node):
	var direction = (global_transform.origin - player.global_transform.origin).normalized() 
	var repel_force = 30.0 
	player.apply_central_impulse(-direction * repel_force)
