extends Node

var available: Dictionary[Types.MyResource, int] = {
	Types.MyResource.Wheat: 0,
	Types.MyResource.Flour: 0,
	Types.MyResource.Bread: 0,
}

func add(type: Types.MyResource, count: int):
	available[type] += count

func myget(type: Types.MyResource):
	return available[type]
