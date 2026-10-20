extends Node

var production: PackedScene = preload("res://scenes/hud/buildings/production/production_window.tscn")

var current_window: CanvasLayer = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_instance_valid(current_window):
		current_window.close()
		get_viewport().set_input_as_handled()

func open(type: Types.WindowType, param: Variant):
	if is_instance_valid(current_window):
		current_window.close()
	match type:
		Types.WindowType.Building:
			current_window = _building_strategy(param)
	
	current_window.init_scene(param)
	add_child(current_window)

func _building_strategy(building: Building) -> CanvasLayer:
	match building.abuilding.type:
		Types.BuildingType.Production:
			return production.instantiate()
		_:
			return production.instantiate()
