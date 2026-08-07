extends Node3D
@onready var area : Area3D = $Area3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and body.has_method("speed_up_tank"):
		body.speed_up_tank()
		queue_free()
