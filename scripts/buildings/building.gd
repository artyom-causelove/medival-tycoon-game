class_name Building
extends Resource

var id: int
var position: Vector3
var rotation: Vector3
var scene_instance: Node3D
var abuilding: Buildings.Abstract

var processes: Array[Process] = []
var level: int = 1

func _init(
	_abuilding: Buildings.Abstract, _id: int,
	_position: Vector3, _rotation: Vector3
):
	id = _id
	position = _position
	rotation = _rotation
	abuilding = _abuilding

func spawn(target_scene: Node3D):
	scene_instance = abuilding.scene.instantiate()
	scene_instance.position = position
	scene_instance.rotation_degrees = rotation
	target_scene.add_child(scene_instance)
	scene_instance.onclick.connect(_onclick)

func delete():
	scene_instance.queue_free()

func _onclick():
	WindowController.open(Types.WindowType.Building, self)
