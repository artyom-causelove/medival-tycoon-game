@tool
class_name Wheat
extends Node3D

enum WheatStage { SPROUT, TILLER, STEM, HEADING, RIPE }

@export var stage: WheatStage = WheatStage.SPROUT:
	set(value):
		stage = value
		if is_node_ready():
			_update_visual()

func _ready() -> void:
	_update_visual()

func _update_visual() -> void:
	$Models/Sprout.visible = stage == WheatStage.SPROUT
	$Models/Tiller.visible = stage == WheatStage.TILLER
	$Models/Stem.visible = stage == WheatStage.STEM
	$Models/Heading.visible = stage == WheatStage.HEADING
	$Models/Ripe.visible = stage == WheatStage.RIPE
