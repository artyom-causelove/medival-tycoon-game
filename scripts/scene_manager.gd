extends Node

func scene(scene_name: String):
	match scene_name:
		"game":
			get_tree().change_scene_to_file("res://scenes/game.tscn")
