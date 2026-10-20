class_name RunButton
extends Control

signal toggled(running: bool)

const RADIUS := 23.8
const RING_WIDTH := 4.2

@export var progress: float = 0.0:
	set(value):
		progress = clamp(value, 0.0, 1.0)
		queue_redraw()

@export var disabled: bool = false:
	set(value):
		disabled = value
		queue_redraw()

var running: bool = false
var hovering: bool = false
var pressing: bool = false

func _ready() -> void:
	custom_minimum_size = Vector2(56, 56)
	mouse_filter = Control.MOUSE_FILTER_STOP

func set_running(value: bool) -> void:
	running = value
	queue_redraw()

func set_progress(ratio: float, is_running: bool) -> void:
	progress = ratio
	set_running(is_running)

func _gui_input(event: InputEvent) -> void:
	if disabled: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			pressing = true
			queue_redraw()
		elif pressing:
			pressing = false
			running = not running
			toggled.emit(running)
			queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		hovering = true
		queue_redraw()
	elif what == NOTIFICATION_MOUSE_EXIT:
		hovering = false
		pressing = false
		queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var brightness := _current_brightness()
	draw_circle(center, RADIUS - RING_WIDTH, ProductionColors.RUN_BG)
	_draw_ring(center, brightness)
	_draw_icon(center, brightness)

func _current_brightness() -> float:
	if disabled or running: return 1.0
	if pressing: return 0.82
	if hovering: return 1.18
	return 1.0

func _draw_ring(center: Vector2, brightness: float) -> void:
	var ring_color := ProductionColors.RUN_RING_DISABLED if disabled else ProductionColors.RUN_RING_IDLE
	if disabled or progress <= 0.0:
		draw_arc(center, RADIUS - RING_WIDTH * 0.5, 0, TAU, 48, ring_color * brightness, RING_WIDTH, true)
	else:
		var end_angle := -PI * 0.5 + TAU * progress
		draw_arc(center, RADIUS - RING_WIDTH * 0.5, -PI * 0.5, end_angle, 48, ProductionColors.RUN_RING_ACTIVE * brightness, RING_WIDTH, true)
		if progress < 1.0:
			draw_arc(center, RADIUS - RING_WIDTH * 0.5, end_angle, PI * 1.5, 48, ring_color * brightness, RING_WIDTH, true)

func _draw_icon(center: Vector2, brightness: float) -> void:
	var icon_color := ProductionColors.RUN_ICON_DISABLED if disabled else ProductionColors.RUN_ICON * brightness
	if running:
		var bar_w := 4.2
		var bar_h := 16.8
		var gap := 4.2
		draw_rect(Rect2(center.x - gap * 0.5 - bar_w, center.y - bar_h * 0.5, bar_w, bar_h), icon_color)
		draw_rect(Rect2(center.x + gap * 0.5, center.y - bar_h * 0.5, bar_w, bar_h), icon_color)
	else:
		var s := 8.4
		var pts := PackedVector2Array([
			Vector2(center.x - s * 0.6, center.y - s),
			Vector2(center.x - s * 0.6, center.y + s),
			Vector2(center.x + s * 0.8, center.y)
		])
		draw_colored_polygon(pts, icon_color)
