class_name BuildTile
extends Button

signal hovered()

var def: BuildingDef

@onready var thumbnail: ModelThumbnail = $Render/Thumbnail
@onready var icon_rect: TextureRect = $Render/Icon
@onready var letter_label: Label = $Render/Letter
@onready var hidden_label: Label = $Render/Hidden
@onready var new_badge: Control = $NewBadge

func _ready() -> void:
	mouse_entered.connect(func(): hovered.emit())

func set_data(_def: BuildingDef) -> void:
	def = _def
	thumbnail.visible = false
	icon_rect.visible = false
	letter_label.visible = false
	hidden_label.visible = false
	new_badge.visible = def.is_new
	disabled = def.hidden
	tooltip_text = "" if def.hidden else def.title

	if def.hidden:
		hidden_label.visible = true
	elif def.preview_scene:
		thumbnail.visible = true
		thumbnail.set_model(def.preview_scene, def.preview_camera_direction)
	elif def.icon:
		icon_rect.visible = true
		icon_rect.texture = def.icon
	else:
		letter_label.visible = true
		letter_label.text = def.title.substr(0, 1).to_upper()

func mark_seen() -> void:
	new_badge.visible = false
