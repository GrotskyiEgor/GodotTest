extends CharacterBody3D

var max_hp : int = 100
var current_hp : int = 0
var speed : float = 3.0

var directions = [
	Vector3.FORWARD,
	Vector3.BACK,
	Vector3.LEFT,
	Vector3.RIGHT
]
var direction

@onready var player_mesh : Node3D = $TankModel
@onready var player_collision : CollisionShape3D = $Collision

@export var shoot_delay : float = 4.0
var can_shoot : bool = true
var shoot_timer : Timer
@onready var bullet_pos : Node3D = $TankModel/ShootPos
@onready var bullet : PackedScene = preload("res://scence/bullet.tscn")

func _ready() -> void:
	current_hp = max_hp
	direction = directions.pick_random()
	
	shoot_timer = Timer.new()
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(func(): can_shoot = true)
	add_child(shoot_timer)

func _physics_process(delta: float) -> void:
	# var vy = velocity.y
	# if not is_on_floor():
	# 	vy += get_gravity().y * delta
		
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	player_mesh.look_at(global_position + direction, Vector3.UP)
	player_mesh.look_at(global_position + direction, Vector3.UP)
	
	#ve
	move_and_slide()

	if get_slide_collision_count() > 0:
		change_direction()
	
	if can_shoot and bullet_pos:
		shoot()
	
func change_direction():
	var new_direction = direction

	while new_direction == direction:
		new_direction = directions.pick_random()

	direction = new_direction
	player_mesh.look_at(global_position + direction, Vector3.UP)
	player_mesh.look_at(global_position + direction, Vector3.UP)

func shoot() -> void:
	can_shoot = false
	shoot_timer.start(shoot_delay)
	
	var instance = bullet.instantiate()
	instance.shoter = self
	instance.position = bullet_pos.global_position
	instance.transform.basis = bullet_pos.global_transform.basis
	instance.scale = Vector3(0.6, 0.6, 0.6)
	get_parent().add_child(instance)
