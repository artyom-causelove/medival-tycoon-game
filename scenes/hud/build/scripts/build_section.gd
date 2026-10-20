class_name BuildSection
extends VBoxContainer

@onready var name_label: Label = $Header/HBox/Name
@onready var tiles: HFlowContainer = $Tiles

func set_title(text: String) -> void:
	name_label.text = text
