extends Node

var wheat = MyResources.myget(Types.MyResource.Wheat)
var flour = MyResources.myget(Types.MyResource.Flour)
var bread = MyResources.myget(Types.MyResource.Bread)

var values: Dictionary[Types.Building, Array] = {
	Types.Building.House: [
		Recipe.new("1 Хлеб", [Ingridient.new(wheat, 2)], bread, 10, 1),
		Recipe.new("1 Хлеб", [Ingridient.new(flour, 1)], bread, 10, 1)
	],
	Types.Building.Windmill: [
		Recipe.new("1 Мука", [Ingridient.new(wheat, 2)], flour, 2, 1),
	],
	Types.Building.PlowedBeds: [
		Recipe.new("1 Пшеница", [], wheat, 4, 1),
	]
}

func myget(type: Types.Building) -> Array[Recipe]:
	var result: Array[Recipe] = []
	result.assign(values[type])
	return result
