extends Node

var values: Dictionary[Types.MyResource, MyResource] = {
	Types.MyResource.Wheat: MyResource.new(
		"Зерно",
		preload("res://assets/textures/resources/wheat_64.png"),
		Types.MyResource.Wheat
	),
	Types.MyResource.Flour: MyResource.new(
		"Мука",
		preload("res://assets/textures/resources/flour_64.png"),
		Types.MyResource.Flour
	),
	Types.MyResource.Bread: MyResource.new(
		"Хлеб",
		preload("res://assets/textures/resources/bread_64.png"),
		Types.MyResource.Bread
	),
}

func myget(type: Types.MyResource) -> MyResource:
	return values[type]
