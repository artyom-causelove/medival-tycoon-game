class_name ResourceSlot
extends TextureRect

@onready var count_label: Label = $CountLabel

func set_data(resource: MyResource, count: int) -> void:
	texture = resource.icon
	count_label.text = str(count)
