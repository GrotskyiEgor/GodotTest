extends Node3D

@onready var area : Area3D = $Area3D
@onready var boad_scence : PackedScene = preload("res://scence/boad.tscn")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.equip_boad(boad_scence)
		queue_free()
