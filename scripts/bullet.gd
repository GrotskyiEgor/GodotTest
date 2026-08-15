extends Area3D

var shoter : Node3D
@export var damage : float = 10.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

@export var speed : float = 15.0

@export var max_life_time : float = 3.0
var lifetime : float = 0.0

func _physics_process(delta: float) -> void:
	lifetime += delta

	if lifetime > max_life_time:
		queue_free()
		return

	var direction : Vector3 = -global_transform.basis.z
	global_position += direction * speed * delta


func _on_body_entered(body: Node3D) -> void:
	if body == shoter or not is_instance_valid(shoter):
		return

	if shoter.is_in_group("player"):
		if body.is_in_group("enemy"):
			body.queue_free()
	elif shoter.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(100)
		
	queue_free()
