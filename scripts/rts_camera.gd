extends Node3D

@export var pan_speed: float = 20.0

@onready var cam: Camera3D = $Camera3D

func _process(delta: float) -> void:
	var forward := -cam.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	var right := cam.global_transform.basis.x
	right.y = 0
	right = right.normalized()

	var input_dir := Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		input_dir += forward
	if Input.is_key_pressed(KEY_S):
		input_dir -= forward
	if Input.is_key_pressed(KEY_D):
		input_dir += right
	if Input.is_key_pressed(KEY_A):
		input_dir -= right

	if input_dir.length() > 0.0:
		global_position += input_dir.normalized() * pan_speed * delta
