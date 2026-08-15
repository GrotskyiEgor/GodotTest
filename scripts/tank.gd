extends CharacterBody3D

enum AnimPlayerState {
	IDLE, 
	MOVE,
}

var animation_state : AnimPlayerState = AnimPlayerState.IDLE
@onready var player_animations : AnimationPlayer = $Model/TankForGodot/AnimationPlayer

@export var speed : float = 5.0
@export var rotation_speed : float = 5.0

@onready var player_mesh : Node3D = $Model
@onready var player_collision : CollisionShape3D = $CollisionShape3D

@onready var bullet_pos : Node3D = $Model/TankForGodot/Turret_001/BulletPos

@onready var bullet : PackedScene = preload("res://scenes/bullet.tscn")

var can_shot : bool = true
@onready var shot_cooldown_timer : Timer = $ShotCooldown

@export var tower_rotation_speed : float = 3.0
@onready var player_tower_mesh : Node3D = $Model/TankForGodot/Turret_001

var alive : bool = true
var max_hp : float = 100.0
var current_hp : float = 0.0

func _ready() -> void:
	current_hp = max_hp
	shot_cooldown_timer.timeout.connect(func(): can_shot = true)

func _process(delta: float) -> void:
	if player_animations:
		match animation_state:
			AnimPlayerState.IDLE:
				player_animations.stop()
			AnimPlayerState.MOVE:
				player_animations.play('Move')

	if not alive:
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	if Input.is_action_pressed("slowdown_rotation"):
		rotation_speed = 2.5
	else: 
		rotation_speed = 5.0

	var move_input : float = Input.get_axis("down", "up")
	var rotation_input : float = Input.get_axis("right", "left")
	var rotation_tower_input : float = Input.get_axis("tower_right", "tower_left")

	if rotation_tower_input:
		player_tower_mesh.rotation.y += rotation_tower_input * tower_rotation_speed * delta

		player_tower_mesh.rotation.y = clamp(
			player_tower_mesh.rotation.y,
			deg_to_rad(-55.0),
			deg_to_rad(55.0)
		)

	if rotation_input:
		player_mesh.rotation.y += rotation_input * rotation_speed * delta
		player_collision.rotation.y = player_mesh.rotation.y


	if move_input:
		var forward : Vector3 = -player_mesh.transform.basis.z
		velocity.x = forward.x * move_input * speed
		velocity.z = forward.z * move_input * speed

		animation_state = AnimPlayerState.MOVE
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * delta * 10)
		velocity.z = move_toward(velocity.z, 0.0, speed * delta * 10)

		animation_state = AnimPlayerState.IDLE

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shot") and can_shot:
		shot()

func shot() -> void:
	can_shot = false
	shot_cooldown_timer.start()

	if not bullet_pos: return

	var instance : Area3D = bullet.instantiate()

	# instance.scale = Vector3(1, 1, 1)
	get_tree().current_scene.add_child(instance)

	instance.global_position = bullet_pos.global_position
	instance.transform.basis = bullet_pos.global_transform.basis
	instance.shoter = self

func take_damage(damage : int) -> void:
	current_hp -= damage

	if current_hp <= 0:
		alive = false
