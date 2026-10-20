@tool
extends Node3D

enum TreeType { NORMAL, BUSHY, OAK, TALL }

@export var tree_type: TreeType = TreeType.NORMAL:
	set(value):
		tree_type = value
		if is_node_ready():
			_update_visual()

func _ready() -> void:
	_update_visual()

func _update_visual() -> void:
	$Models/Normal.visible = tree_type == TreeType.NORMAL
	$Models/Bushy.visible = tree_type == TreeType.BUSHY
	$Models/Oak.visible = tree_type == TreeType.OAK
	$Models/Tall.visible = tree_type == TreeType.TALL
