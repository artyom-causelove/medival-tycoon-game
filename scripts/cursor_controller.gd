extends Node

const FRAME_SIZE := 64
const FRAME_COUNT := 6
const FRAME_DURATION := 1.0 / 22.0
const HOTSPOT := Vector2(7, 6)

var idle_flat: Texture2D = preload("res://assets/textures/cursors/pointer_flat.png")
var idle_select: Texture2D = preload("res://assets/textures/cursors/select_gold_glow.png")
var press_flat_strip: Texture2D = preload("res://assets/textures/cursors/pointer_press_strip.png")
var press_select_strip: Texture2D = preload("res://assets/textures/cursors/select_glow_press_strip.png")

var hovering: bool = false
var pressing: bool = false
var press_frame: int = 0
var press_timer: float = 0.0
var last_selecting = null

func _ready() -> void:
	_set_idle_cursor()

func _process(delta: float) -> void:
	if not pressing:
		_set_idle_cursor()
		return
	press_timer += delta
	if press_timer < FRAME_DURATION:
		return
	press_timer = 0.0
	press_frame += 1
	if press_frame >= FRAME_COUNT:
		pressing = false
		_set_idle_cursor()
	else:
		_set_press_frame(press_frame)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pressing = true
		press_frame = 0
		press_timer = 0.0
		_set_press_frame(0)

func set_hovering(value: bool) -> void:
	hovering = value

func _is_selecting() -> bool:
	if is_instance_valid(WindowController.current_window):
		return false
	return hovering and get_viewport().gui_get_hovered_control() == null

func _set_idle_cursor() -> void:
	var selecting := _is_selecting()
	if selecting == last_selecting:
		return
	last_selecting = selecting
	Input.set_custom_mouse_cursor(idle_select if selecting else idle_flat, Input.CURSOR_ARROW, HOTSPOT)

func _set_press_frame(frame: int) -> void:
	var strip := press_select_strip if _is_selecting() else press_flat_strip
	var atlas := AtlasTexture.new()
	atlas.atlas = strip
	atlas.region = Rect2(frame * FRAME_SIZE, 0, FRAME_SIZE, FRAME_SIZE)
	Input.set_custom_mouse_cursor(atlas, Input.CURSOR_ARROW, HOTSPOT)
