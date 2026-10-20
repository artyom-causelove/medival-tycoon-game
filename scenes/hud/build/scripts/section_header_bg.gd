extends Control

const TOP_COLOR := Color("#2b3234")
const BOTTOM_COLOR := Color("#242b2d")
const HAIRLINE := Color(0.6901961, 0.5529412, 0.3098039, 0.35)

func _draw() -> void:
	var w := size.x
	var h := size.y
	var pts := PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, h), Vector2(0, h)])
	var colors := PackedColorArray([TOP_COLOR, TOP_COLOR, BOTTOM_COLOR, BOTTOM_COLOR])
	draw_polygon(pts, colors)
	draw_rect(Rect2(0, h - 1, w, 1), HAIRLINE)
