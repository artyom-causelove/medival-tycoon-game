extends Node3D

@export var speed: float = 0.9

func _process(delta: float) -> void:
	rotate_x(delta * speed)
