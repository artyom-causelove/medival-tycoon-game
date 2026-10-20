class_name BuildingDef
extends Resource

var id: StringName
var title: String
var category: StringName
var description: String
var price_lines: Array[String]
var icon: Texture2D

## Необязательные поля для живого 3D-превью в карточке (вместо плоской
## icon-картинки) — если preview_scene не задан, карточка просто покажет icon.
## preview_camera_direction — ракурс (направление, откуда смотрит камера);
## дистанция под кадр считается автоматически от реального AABB модели.
var preview_scene: PackedScene
var preview_camera_direction: Vector3

## Размер участка (ромба) в мире, метры — пока чисто информационное поле,
## реальной проверки занятости участка в этой версии нет.
var footprint: float
## Скрытая постройка — плитка показывает "?", клик по ней игнорируется.
var hidden: bool
## Новая постройка — плитка показывает жёлтый ромб-метку, пока игрок не наведётся и не уйдёт.
var is_new: bool

func _init(
	_id: StringName = &"", _title: String = "", _category: StringName = &"",
	_description: String = "", _price_lines: Array[String] = [], _icon: Texture2D = null,
	_preview_scene: PackedScene = null, _preview_camera_direction: Vector3 = Vector3(1, 0.8, 1),
	_footprint: float = 3.0, _hidden: bool = false, _is_new: bool = false
):
	id = _id
	title = _title
	category = _category
	description = _description
	price_lines = _price_lines
	icon = _icon
	preview_scene = _preview_scene
	preview_camera_direction = _preview_camera_direction
	footprint = _footprint
	hidden = _hidden
	is_new = _is_new
