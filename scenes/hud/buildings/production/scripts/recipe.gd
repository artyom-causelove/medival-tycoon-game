class_name RecipeBlock
extends NinePatchRect

signal production_toggled(running: bool)

var icon: Texture2D
var selected: bool
var title: String
var desc: String
var running: bool = false

@onready var run_button: RunButton = $RunButton

func init_scene(_title: String, _icon: Texture2D, _selected: bool = false):
	selected = _selected
	title = _title
	icon = _icon

func set_selected(status: bool):
	selected = status
	$Sel.visible = status

func set_progress(ratio: float, is_running: bool) -> void:
	run_button.set_progress(ratio, is_running)

func _ready():
	$Sel.visible = selected
	$Icon.texture = icon
	$Title.text = title
	$Desc.text = desc
	run_button.toggled.connect(_on_run_button_toggled)

func _on_run_button_toggled(is_running: bool):
	running = is_running
	production_toggled.emit(running)
