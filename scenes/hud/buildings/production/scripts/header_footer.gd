extends Control

const BORDER_WIDTH := 4.2

@export var flip_gradient: bool = false
@export var border_on_bottom: bool = true

func _draw() -> void:
	var w := size.x
	var h := size.y
	var top_color = ProductionColors.PANEL_GRADIENT_BOTTOM if flip_gradient else ProductionColors.PANEL_GRADIENT_TOP
	var bottom_color = ProductionColors.PANEL_GRADIENT_TOP if flip_gradient else ProductionColors.PANEL_GRADIENT_BOTTOM
	var pts := PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, h), Vector2(0, h)])
	var colors := PackedColorArray([top_color, top_color, bottom_color, bottom_color])
	draw_polygon(pts, colors)
	if border_on_bottom:
		draw_rect(Rect2(0, h - BORDER_WIDTH, w, BORDER_WIDTH), ProductionColors.DARK_BORDER)
	else:
		draw_rect(Rect2(0, 0, w, BORDER_WIDTH), ProductionColors.DARK_BORDER)
