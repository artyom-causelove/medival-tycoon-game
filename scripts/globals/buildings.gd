extends Node

var values: Dictionary[Types.Building, Abstract] = {
	Types.Building.House: Abstract.new(
		"ДОМ",
		Types.BuildingType.Production,
		preload("res://scenes/buildings/house.tscn"),
		Recipes.myget(Types.Building.House)
	),
	Types.Building.Windmill: Abstract.new(
		"МЕЛЬНИЦА",
		Types.BuildingType.Production,
		preload("res://scenes/buildings/windmill.tscn"),
		Recipes.myget(Types.Building.Windmill)
	),
	Types.Building.PlowedBeds: Abstract.new(
		"ГРЯДКИ",
		Types.BuildingType.Production,
		preload("res://scenes/plowed_beds.tscn"),
		Recipes.myget(Types.Building.PlowedBeds)
	),
}

func myget(type: Types.Building) -> Abstract:
	return values[type]

class Abstract:
	var title: String
	var type: Types.BuildingType
	var scene: PackedScene
	var recipes: Array[Recipe]
	
	func _init(
		_title: String, _type: Types.BuildingType, _scene: PackedScene,
		_recipes: Array[Recipe]
	):
		title = _title
		type = _type
		scene = _scene
		recipes = _recipes
