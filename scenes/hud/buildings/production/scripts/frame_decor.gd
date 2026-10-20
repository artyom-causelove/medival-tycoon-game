extends Control

const ARM := 21.0
const THICK := 5.6
const OFFSET := 9.8

func _draw() -> void:
	var w := size.x
	var h := size.y
	_bracket(Vector2(OFFSET, OFFSET), Vector2(1, 1))
	_bracket(Vector2(w - OFFSET, OFFSET), Vector2(-1, 1))
	_bracket(Vector2(OFFSET, h - OFFSET), Vector2(1, -1))
	_bracket(Vector2(w - OFFSET, h - OFFSET), Vector2(-1, -1))

func _bracket(corner: Vector2, dir: Vector2) -> void:
	draw_rect(_rect_from(corner, Vector2(dir.x * ARM, dir.y * THICK)), ProductionColors.GOLD_BRIGHT)
	draw_rect(_rect_from(corner, Vector2(dir.x * THICK, dir.y * ARM)), ProductionColors.GOLD_BRIGHT)
	var rivet_center := corner + dir * 13.3
	draw_circle(rivet_center, 3.4, ProductionColors.RIVET_DARK)
	draw_circle(rivet_center - dir * 0.98, 1.96, ProductionColors.RIVET_LIGHT)

func _rect_from(corner: Vector2, delta: Vector2) -> Rect2:
	var origin := Vector2(min(corner.x, corner.x + delta.x), min(corner.y, corner.y + delta.y))
	return Rect2(origin, delta.abs())
