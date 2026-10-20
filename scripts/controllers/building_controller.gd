extends Node

var game_scene: Node3D
var buildings: Array[Building] = []

func add_building(type: Types.Building, position: Vector3, rotation: Vector3):
	var new = Building.new(Buildings.myget(type), buildings.size(), position, rotation)
	new.spawn(game_scene)
	buildings.append(new)
