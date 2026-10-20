extends CanvasLayer

var _popup: PopupMenu
var _callback: Callable

func _ready() -> void:
	get_tree().root.physics_object_picking = true
	_popup = PopupMenu.new()
	add_child(_popup)
	_popup.id_pressed.connect(_on_id_pressed)

func show_options(options: Array, screen_pos: Vector2, callback: Callable) -> void:
	_callback = callback
	_popup.clear()
	for i in range(options.size()):
		_popup.add_item(String(options[i]), i)
	_popup.position = Vector2i(screen_pos)
	_popup.popup()

func _on_id_pressed(id: int) -> void:
	if _callback.is_valid():
		_callback.call(id)
