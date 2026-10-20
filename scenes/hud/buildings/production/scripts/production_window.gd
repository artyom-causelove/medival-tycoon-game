extends CanvasLayer

var main_view_packed: PackedScene = preload("res://scenes/hud/buildings/production/main_view.tscn")
var upgrade_minor_packed: PackedScene = preload("res://scenes/hud/buildings/production/upgrade_minor_view.tscn")

var building: Building
var main_scene: MainView
var upgrade_minor_scene: UpgradeMinorView
var current_button: Control
var current_scene: Node
var original_normal: Dictionary = {}
var original_hover: Dictionary = {}

@onready var backdrop: ColorRect = $Backdrop
@onready var root: Control = $Root
@onready var title_cartouche: TitleCartouche = $Root/TitleCartouche
@onready var upgrade_minor_button: Button = $Root/UpgradeMinorButton
@onready var close_button: Button = $Root/CloseButton
@onready var main_button: Button = $Root/MainButton

func init_scene(_building: Building):
	building = _building

func close(event = null):
	if event == null or Events.isMouseLeftClick(event):
		queue_free()

func _ready():
	_instantiate_scenes()
	_capture_original_styles()
	_set_current(main_scene, main_button)
	_apply_building()
	_apply_signals()

func _instantiate_scenes():
	main_scene = main_view_packed.instantiate() as MainView
	upgrade_minor_scene = upgrade_minor_packed.instantiate() as UpgradeMinorView
	main_scene.init_scene(building, building.abuilding.recipes)
	upgrade_minor_scene.init_scene()
	upgrade_minor_scene.visible = false
	root.add_child(main_scene)
	root.add_child(upgrade_minor_scene)

func _capture_original_styles():
	for button in [main_button, upgrade_minor_button]:
		original_normal[button] = button.get_theme_stylebox("normal")
		original_hover[button] = button.get_theme_stylebox("hover")

func _set_current(scene: Node, button: Control):
	if scene == current_scene: return
	if is_instance_valid(current_scene):
		current_scene.visible = false
		_set_button_active(current_button, false)
	current_scene = scene
	current_button = button
	_set_button_active(current_button, true)
	current_scene.visible = true

func _set_button_active(button: Control, active: bool):
	if active:
		var style = button.get_theme_stylebox("pressed")
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)
	else:
		button.add_theme_stylebox_override("normal", original_normal[button])
		button.add_theme_stylebox_override("hover", original_hover[button])

func _apply_building():
	title_cartouche.set_data(building.abuilding.title, building.level)

func _apply_signals():
	backdrop.gui_input.connect(close)
	close_button.pressed.connect(close)
	upgrade_minor_button.pressed.connect(_set_current.bind(upgrade_minor_scene, upgrade_minor_button))
	main_button.pressed.connect(_set_current.bind(main_scene, main_button))
	main_scene.production_toggled.connect(_on_production_toggled)

func _on_production_toggled(recipe: Recipe, running: bool):
	var proc: Process = Func.find(building.processes, recipe, "recipe")
	if proc and !running:
		return proc.stop()
	if proc and running:
		return proc.resume()
	proc = Process.new(recipe)
	var created = ProductionController.add_process(proc)
	if created:
		building.processes.append(proc)
