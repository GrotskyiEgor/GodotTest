extends CharacterBody3D

@export var speed : float = 15.0
@export var damage : float = 10
@export var max_life_time : float = 3.0

var shoter : Node3D
var lifetime : float = 0.0

func _ready():
	if shoter and shoter is CollisionObject3D:
		add_collision_exception_with(shoter)

func _physics_process(delta: float) -> void:
	lifetime += delta
	
	if lifetime > max_life_time:
		queue_free()
		return
	
	velocity = -global_transform.basis.z * speed
	var collision = move_and_collide(velocity * delta)
		
	if collision:
		var collider = collision.get_collider()
		
		if collider == shoter:
			return
		
		if shoter:
			if shoter.is_in_group("player"):
				if collider.is_in_group("enemy"):
					shoter.update_kills()
					collider.queue_free()
				elif collider.is_in_group("wall"):
					collider.get_parent().queue_free()
			elif shoter.is_in_group("enemy"):
				if collider.has_method("take_damage"):
					collider.take_damage(100)
					
		queue_free()
