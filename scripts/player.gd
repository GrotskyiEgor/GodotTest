extends CharacterBody3D

@onready var player_mesh : Node3D = $TankModel
@onready var player_collision : CollisionShape3D = $Collision
@onready var camera_privot : Node3D = $Camera

enum AnimPlayerState {
	IDLE, 
	MOVE,
}

var animation_state : AnimPlayerState = AnimPlayerState.IDLE
@onready var player_animations : AnimationPlayer = $TankModel/TankForGodot/AnimationPlayer

var alive : bool = true
var max_hp : int = 100
var current_hp : int = 0
var speed : float = 2.5
var speed_up : float = 0.0
var rotation_speed : float = 5.0
var has_boat : bool = false
@onready var boat_pos : Node3D = $TankModel/BoatPos

var shot_delay : float = 0.5
var can_shot : bool = true
var shot_timer : Timer

@export var tower_rotation_speed : float = 3.0
@onready var player_tower_mesh : Node3D = $TankModel/TankForGodot/Turret_001

@onready var bullet_pos : Node3D = $TankModel/TankForGodot/Turret_001/ShootPos
@onready var bullet : PackedScene = preload("res://scence/bullet.tscn")
@onready var muzzle_flash : GPUParticles3D = $TankModel/TankForGodot/Turret_001/MuzzleFlash

@onready var speed_up_timer : Timer = $SpeedUpTimer

var kill_count : int = 0
var enemy_count : int
@onready var enemy_node : Node3D = $"../Enemy"


@onready var hurt_sound : AudioStreamPlayer3D = $Sounds/Hurt
@onready var shot_sound : AudioStreamPlayer3D = $Sounds/Shot

@onready var walk_sound : AudioStreamPlayer3D = $Sounds/Move
@onready var idle_sound : AudioStreamPlayer3D = $Sounds/Idle
@onready var take_sound : AudioStreamPlayer3D = $Sounds/Take

@onready var lose_sound : AudioStreamPlayer3D = $Sounds/Lose
@onready var win_sound : AudioStreamPlayer3D = $Sounds/Win
@onready var game_menu = $"../../Menu"

@onready var main_music : AudioStreamPlayer3D = $"../../Music/Main"

var mouse_sens := 0.003
var camera_x := 0.0

func _ready() -> void:
	current_hp = max_hp
	
	if enemy_node:
		print(enemy_count)
		enemy_count = enemy_node.get_child_count()

	print(enemy_count)
	
	shot_timer = Timer.new()
	shot_timer.one_shot = true
	shot_timer.timeout.connect(func(): can_shot = true)
	add_child(shot_timer)
	
	speed_up_timer.timeout.connect(func(): speed_up = 0.0)

func _process(delta: float) -> void:
	if player_animations:
		match animation_state:
			AnimPlayerState.IDLE:
				player_animations.stop()
			AnimPlayerState.MOVE:
				player_animations.play('Move')

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	var rotation_input := 0.0

	if Input.is_action_pressed("left"):
		rotation_input += 1.0

	if Input.is_action_pressed("right"):
		rotation_input -= 1.0

	if rotation_input != 0.0:
		player_mesh.rotation.y += rotation_input * rotation_speed * delta
		player_collision.rotation.y = player_mesh.rotation.y

	var move_input := 0.0

	if Input.is_action_pressed("up"):
		move_input += 1.0

	if Input.is_action_pressed("down"):
		move_input -= 1.0

	var move_speed := speed + speed_up

	var rotation_tower_input : float = Input.get_axis("tower_right", "tower_left")

	if rotation_tower_input:
		player_tower_mesh.rotation.y += rotation_tower_input * tower_rotation_speed * delta

		player_tower_mesh.rotation.y = clamp(
			player_tower_mesh.rotation.y,
			deg_to_rad(-55.0),
			deg_to_rad(55.0)
		)

	if move_input and alive:
		var forward := -player_mesh.global_transform.basis.z

		velocity.x = forward.x * move_input * move_speed
		velocity.z = forward.z * move_input * move_speed

		animation_state = AnimPlayerState.MOVE

		if idle_sound.playing:
			idle_sound.stop()

		if not walk_sound.playing:
			walk_sound.play()
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * delta * 10)
		velocity.z = move_toward(velocity.z, 0.0, speed * delta * 10)

		animation_state = AnimPlayerState.IDLE

		if walk_sound.playing:
			walk_sound.stop()

		if not idle_sound.playing:
			idle_sound.play()

	move_and_slide()
	
	if Input.is_action_pressed("shot") and can_shot and bullet_pos:
		shot()

func speed_up_tank() -> void:
	speed_up += 3
	speed_up_timer.start()
	
func equip_boad(boad_scence : PackedScene) -> void:
	if boat_pos.get_child_count() > 0:
		for child in boat_pos.get_children():
			child.queue_free()
	
	var new_boat = boad_scence.instantiate()
	boat_pos.add_child(new_boat)
	new_boat.position = Vector3.ZERO
	new_boat.rotation = Vector3.ZERO
	new_boat.process_mode = Node.PROCESS_MODE_DISABLED
	
	has_boat = true
	
func take_damage(damage : int) -> void:
	current_hp -= damage
	
	if current_hp <= 0:
		alive = false
		main_music.stop()
		lose_sound.play()
		await lose_sound.finished
		main_music.play()
		game_menu.show_lose()
		
func update_kills() -> void:
	kill_count += 1
	
	if kill_count == enemy_count:
		alive = false
		main_music.stop()
		win_sound.play()
		await win_sound.finished
		main_music.play()
		game_menu.show_win()
	else: 
		hurt_sound.play()

func shot() -> void:
	can_shot = false
	shot_timer.start(shot_delay)
	
	muzzle_flash.restart()

	var instance = bullet.instantiate()
	instance.shoter = self
	instance.position = bullet_pos.global_position
	instance.transform.basis = bullet_pos.global_transform.basis
	instance.scale = Vector3(0.6, 0.6, 0.6)
	get_parent().add_child(instance)
	
	shot_sound.play()


func _on_shoot_button_down() -> void:
	Input.action_press("shot")


func _on_shoot_button_up() -> void:
	Input.action_release("shot")
