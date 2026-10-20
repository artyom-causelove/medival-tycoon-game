class_name MainView
extends Control

signal production_toggled(recipe: Recipe, running: bool)

const PROGRESS_BAR_WIDTH := 420.0

var recipe_packed: PackedScene = preload("res://scenes/hud/buildings/production/recipe.tscn")
var resource_slot_packed: PackedScene = preload("res://scenes/hud/buildings/production/resource_slot.tscn")
var building: Building
var selected_recipe_scene: RecipeBlock
var selected_recipe: Recipe
var recipes: Array[Recipe]

@onready var recipes_list: VBoxContainer = $RecipesScroll/RecipesList
@onready var ingredients_box: HBoxContainer = $PanelInProgress/RecipeRow/IngredientsBox
@onready var result_slot: ResourceSlot = $PanelInProgress/RecipeRow/ResultSlot
@onready var progress_fill: TextureRect = $PanelInProgress/ProgressBg/ProgressFill
@onready var status_label: Label = $PanelInProgress/StatusLabel

func init_scene(_building: Building, _recipes: Array[Recipe] = []):
	building = _building
	recipes = _recipes

func _ready():
	_populate_recipes()
	_apply_recipe_slots(selected_recipe)

func _populate_recipes():
	for child in recipes_list.get_children():
		child.queue_free()
	for i in range(recipes.size()):
		_add_recipe_row(recipes[i], i == 0)

func _add_recipe_row(recipe: Recipe, is_first: bool) -> void:
	var recipe_scene: RecipeBlock = recipe_packed.instantiate() as RecipeBlock
	recipe_scene.init_scene(recipe.title, recipe.result.icon, is_first)
	if is_first:
		selected_recipe_scene = recipe_scene
		selected_recipe = recipe
	recipe_scene.gui_input.connect(_toggle_selected_recipe.bind(recipe_scene, recipe))
	recipe_scene.production_toggled.connect(_on_recipe_production_toggled.bind(recipe))
	recipes_list.add_child(recipe_scene)

func _on_recipe_production_toggled(running: bool, recipe: Recipe):
	production_toggled.emit(recipe, running)

func _toggle_selected_recipe(event, scene: RecipeBlock, recipe: Recipe):
	if Events.isMouseLeftClick(event):
		selected_recipe_scene.set_selected(false)
		selected_recipe_scene = scene
		selected_recipe = recipe
		selected_recipe_scene.set_selected(true)
		_apply_recipe_slots(recipe)
		_apply_selected_progress(_find_process(recipe))

func _apply_recipe_slots(recipe: Recipe) -> void:
	for child in ingredients_box.get_children():
		child.queue_free()
	if recipe == null:
		result_slot.visible = false
		return
	result_slot.visible = true
	for ingridient in recipe.ingridients:
		var slot := resource_slot_packed.instantiate() as ResourceSlot
		ingredients_box.add_child(slot)
		slot.set_data(ingridient.resource, ingridient.count)
	result_slot.set_data(recipe.result, recipe.result_count)

func _process(_delta: float) -> void:
	var selected_proc: Process = null
	for i in range(recipes.size()):
		var recipe_scene: RecipeBlock = recipes_list.get_child(i) as RecipeBlock
		var proc: Process = _sync_recipe_row(recipe_scene, recipes[i])
		if recipes[i] == selected_recipe:
			selected_proc = proc
	_apply_selected_progress(selected_proc)

func _sync_recipe_row(recipe_scene: RecipeBlock, recipe: Recipe) -> Process:
	var proc: Process = _find_process(recipe)
	var ratio: float = proc.current / proc.recipe.needs if proc else 0.0
	var running: bool = proc != null and proc.is_running()
	recipe_scene.set_progress(ratio, running)
	return proc

func _find_process(recipe: Recipe) -> Process:
	return Func.find(building.processes, recipe, "recipe")

func _apply_selected_progress(proc: Process) -> void:
	if proc:
		var ratio: float = proc.current / proc.recipe.needs
		progress_fill.size.x = PROGRESS_BAR_WIDTH * ratio
		status_label.text = "В работе: %d%%" % int(ratio * 100)
	else:
		progress_fill.size.x = 0.0
		status_label.text = "Не запущено"
