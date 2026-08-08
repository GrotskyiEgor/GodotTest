extends CharacterBody3D

@onready var player_mesh : Node3D = $TankModel
@onready var player_collision : CollisionShape3D = $Collision
@onready var camera_privot : Node3D = $Camera

var alive : bool = true
var max_hp : int = 100
var current_hp : int = 0
var speed : float = 2.5
var speed_up : float = 0.0
var has_boat : bool = false
@onready var boat_pos : Node3D = $TankModel/BoatPos

var shot_delay : float = 0.5
var can_shot : bool = true
var shot_timer : Timer
@onready var bullet_pos : Node3D = $TankModel/ShootPos
@onready var bullet : PackedScene = preload("res://scence/bullet.tscn")

@onready var speed_up_timer : Timer = $SpeedUpTimer

var kill_count : int = 0
var enemy_count : int
@onready var enemy_node : Node3D = $"../Enemy"

@onready var thow_sound : AudioStreamPlayer3D = $Sounds/Thow
@onready var hurt_sound : AudioStreamPlayer3D = $Sounds/Hurt
@onready var shot_sound : AudioStreamPlayer3D = $Sounds/Shoot
@onready var walk_sound : AudioStreamPlayer3D = $Sounds/Walk
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

func _physics_process(delta: float) -> void:
	var direction := Vector3.ZERO
	
	# if Input.is_action_pressed("up"):
	# 	direction = Vector3(0, 0, -1)
	# elif Input.is_action_pressed("down"):
	# 	direction = Vector3(0, 0, 1)
	# elif Input.is_action_pressed("left"):
	# 	direction = Vector3(-1, 0, 0)
	# elif Input.is_action_pressed("right"):
	# 	direction = Vector3(1, 0, 0)

	var input := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	if abs(input.x) > abs(input.y):
		direction = Vector3(sign(input.x), 0.0, 0.0)
	else:
		direction = Vector3(0.0, 0.0, sign(input.y))

	if direction != Vector3.ZERO and alive:
		velocity.x = direction.x * (speed + speed_up)
		velocity.z = direction.z * (speed + speed_up)

		var target_rotation = atan2(-direction.x, -direction.z)
		player_mesh.global_rotation.y = target_rotation
		player_collision.global_rotation.y = target_rotation
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * delta * 10)
		velocity.z = move_toward(velocity.z, 0.0, speed * delta * 10)

	move_and_slide()
	
	if Input.is_action_pressed("shot") and can_shot and bullet_pos:
		#shot_sound.play()
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
	thow_sound.play()
	
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
