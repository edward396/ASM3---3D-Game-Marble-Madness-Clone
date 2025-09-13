extends Node3D

@export var chase_speed: float = 5
@export var repel_force: float = 50.0
@onready var player: Node3D = $"../Ball"  
@onready var chase_area: Area3D =  $Area3D2
@onready var collision_area: Area3D = $ColliArea3D

var _is_chasing: bool = false
var _target_position: Vector3

func _ready():
	
	add_to_group("enemy")
	
	# Kết nối tín hiệu của Area3D để phát hiện khi người chơi vào khu vực
	chase_area.body_entered.connect(_on_area_entered)
	chase_area.body_exited.connect(_on_area_exited)
	collision_area.body_entered.connect(_on_collision_with_body)

func _physics_process(delta):
	if _is_chasing:
		_target_position = player.global_transform.origin
		var direction = (_target_position - global_transform.origin).normalized()
		
		velocity = direction * chase_speed 
		move_and_slide() 

func _on_area_entered(body: Node):
	if body == player:
		_is_chasing = true
		_target_position = player.global_transform.origin

func _on_area_exited(body: Node):
	if body == player:
		_is_chasing = false
		_target_position = Vector3.ZERO

func _on_collision_with_body(body: Node):
	if body == player and body.has_method("repel_from"):
		var direction = (global_transform.origin - player.global_transform.origin).normalized() 
		var repelforce = 50.0  # Độ mạnh của lực đẩy
		velocity = direction * repelforce
		move_and_slide() 		

func start_chasing():
	_is_chasing = true
	_target_position = player.global_transform.origin 

func stop_chasing():
	_is_chasing = false
	_target_position = Vector3.ZERO 
 
