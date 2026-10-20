class_name TitleCartouche
extends Control

const SKEW := 19.6
const PAD_LEFT := 33.6
const PAD_RIGHT := 28.0
const GAP := 20.0

@onready var name_label: Label = $Name
@onready var diamond: Polygon2D = $Diamond
@onready var level_label: Label = $Level

func set_data(building_title: String, level: int) -> void:
	name_label.text = building_title
	level_label.visible = true
	level_label.text = "Уровень " + Parsers.to_roman(level)
	_relayout()

func _relayout() -> void:
	name_label.position.x = PAD_LEFT
	name_label.size.x = name_label.get_minimum_size().x
	var right_edge := name_label.position.x + name_label.size.x
	diamond.position.x = right_edge + GAP
	right_edge = diamond.position.x + GAP
	if level_label.visible:
		level_label.position.x = right_edge
		level_label.size.x = level_label.get_minimum_size().x
		right_edge = level_label.position.x + level_label.size.x
	size.x = right_edge + PAD_RIGHT
	queue_redraw()

func _ready() -> void:
	diamond.rotation_degrees = 45.0
	diamond.polygon = PackedVector2Array([
		Vector2(-4.9, -4.9), Vector2(4.9, -4.9), Vector2(4.9, 4.9), Vector2(-4.9, 4.9)
	])
	diamond.color = ProductionColors.GOLD_ACCENT
	_relayout()

func _draw() -> void:
	var w := size.x
	var h := size.y
	var pts := PackedVector2Array([
		Vector2(SKEW, 0), Vector2(w, 0), Vector2(w - SKEW, h), Vector2(0, h)
	])
	var colors := PackedColorArray([
		ProductionColors.PANEL_GRADIENT_TOP, ProductionColors.PANEL_GRADIENT_TOP,
		ProductionColors.PANEL_GRADIENT_BOTTOM, ProductionColors.PANEL_GRADIENT_BOTTOM
	])
	draw_polygon(pts, colors)
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), ProductionColors.RIVET_DARK, 2.8, true)
