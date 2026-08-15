extends CharacterBody3D

var max_hp : int = 100
var current_hp : int = 0

var speed : float = 5.0
var rotation_speed : float = 5.0

@onready var player_mesh : Node3D = $Model
@onready var player_collision : CollisionShape3D = $CollisionShape3D

@onready var bullet_pos : Node3D = $Model/BulletPos
@onready var bullet : PackedScene = preload("res://scenes/bullet.tscn")

var can_shot : bool = true
@onready var shot_cooldown_timer : Timer = $ShotCooldown

var direction : Vector3
var directions = [
	Vector3.FORWARD,
	Vector3.BACK,
	Vector3.LEFT,
	Vector3.RIGHT
]

func _ready() -> void:
	direction = directions.pick_random()
	shot_cooldown_timer.timeout.connect(func(): can_shot = true)

	current_hp = max_hp
	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
		
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	var target_rotation : float = atan2(-direction.x, -direction.z)

	player_mesh.rotation.y = lerp_angle(
		player_mesh.rotation.y,
		target_rotation,
		rotation_speed * delta
	)

	move_and_slide()

	if get_slide_collision_count() > 0:
		change_direction()
	
	if can_shot and bullet_pos:
		shoot()
	
func change_direction():
	var new_direction = direction

	while new_direction == direction:
		new_direction = directions.pick_random()

	direction = new_direction

func shoot() -> void:
	can_shot = false
	shot_cooldown_timer.start()
	
	var instance : Area3D  = bullet.instantiate()

	# instance.scale = Vector3(1, 1, 1)
	get_parent().add_child(instance)

	instance.shoter = self
	instance.position = bullet_pos.global_position
	instance.transform.basis = bullet_pos.global_transform.basis
	
