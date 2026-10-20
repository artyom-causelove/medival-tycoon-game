class_name ModelThumbnail
extends SubViewportContainer

const FIT_MARGIN := 0.85

@onready var viewport: SubViewport = $SubViewport
@onready var camera: Camera3D = $SubViewport/Camera3D
@onready var model_slot: Node3D = $SubViewport/ModelSlot

var current_model: Node3D

## camera_direction — единичный (или любой) вектор направления, откуда камера
## смотрит на модель; ракурс задаётся вручную per-building. Дистанция же не
## угадывается — считается от реального AABB модели, чтобы не ловить обрезанные
## кадры на моделях разного размера.
func set_model(scene: PackedScene, camera_direction: Vector3) -> void:
	if current_model:
		current_model.queue_free()
		current_model = null
	if scene == null:
		return
	current_model = scene.instantiate()
	model_slot.add_child(current_model)
	_freeze(current_model)
	_frame_camera(current_model, camera_direction)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func _frame_camera(model: Node3D, camera_direction: Vector3) -> void:
	var aabb := _model_aabb(model)
	var center := aabb.get_center()
	var radius := aabb.size.length() * 0.5
	var distance := (radius / sin(deg_to_rad(camera.fov) * 0.5)) * FIT_MARGIN
	camera.position = center + camera_direction.normalized() * distance
	camera.look_at(center, Vector3.UP)

func _model_aabb(model: Node3D) -> AABB:
	var result := AABB()
	var first := true
	for mesh in _mesh_instances(model):
		var world_aabb: AABB = mesh.global_transform * mesh.get_aabb()
		if first:
			result = world_aabb
			first = false
		else:
			result = result.merge(world_aabb)
	return result

func _mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		result.append(node)
	for child in node.get_children():
		result.append_array(_mesh_instances(child))
	return result

## Глушит любую анимацию модели (AnimationPlayer и скрипты вроде spinner.gd,
## которые крутят что-то в _process) — превью должно быть статичным кадром.
func _freeze(node: Node) -> void:
	node.set_process(false)
	node.set_physics_process(false)
	if node is AnimationPlayer:
		node.stop()
	for child in node.get_children():
		_freeze(child)
