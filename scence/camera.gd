extends Node3D

const MOUSE_SENTESIVITY : float = 0.005

#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#rotation.y -= event.relative.x * MOUSE_SENTESIVITY
