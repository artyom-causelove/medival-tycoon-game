@tool
class_name BuildingVisual
extends Node3D

signal onclick

@export var level: int = 1:
	set(value):
		level = value
		if is_node_ready():
			_update_visual()

@onready var click_area = $Collision
@onready var models: Node3D = $Models

var rim_material: ShaderMaterial = preload("res://assets/materials/building_rim_highlight.tres")

func _ready():
	_update_visual()
	if not Engine.is_editor_hint():
		click_area.input_event.connect(_on_input_event)
		click_area.mouse_entered.connect(_on_mouse_entered)
		click_area.mouse_exited.connect(_on_mouse_exited)

func _update_visual():
	for i in models.get_child_count():
		models.get_child(i).visible = (i + 1) == level

func _on_input_event(_camera, event, _click_position, _normal, _shape_idx):
	if is_instance_valid(WindowController.current_window): return
	if Events.isMouseLeftClick(event): onclick.emit()

func _on_mouse_entered():
	CursorController.set_hovering(true)
	_set_rim_highlight(true)

func _on_mouse_exited():
	CursorController.set_hovering(false)
	_set_rim_highlight(false)

func _set_rim_highlight(enabled: bool):
	if level - 1 >= models.get_child_count(): return
	var active_model = models.get_child(level - 1)
	for mesh in _find_mesh_instances(active_model):
		_get_highlight_mesh(mesh).visible = enabled

# A separate opaque-queue duplicate instead of material_overlay: an overlay
# pass shares its parent mesh's transparency queue, so it silently fails to
# draw on meshes using alpha transparency. A standalone instance with the
# rim shader as its own material isn't affected by the source mesh's
# transparency mode at all.
func _get_highlight_mesh(mesh: MeshInstance3D) -> MeshInstance3D:
	var highlight := mesh.get_node_or_null("HighlightOverlay") as MeshInstance3D
	if highlight == null:
		highlight = MeshInstance3D.new()
		highlight.name = "HighlightOverlay"
		highlight.mesh = mesh.mesh
		highlight.material_override = rim_material
		highlight.visible = false
		mesh.add_child(highlight)
	return highlight

func _find_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		# Don't recurse into it: that's exactly where _get_highlight_mesh
		# parents its injected duplicate, and finding that duplicate here
		# on the next hover would spawn a highlight of the highlight.
		result.append(node)
		return result
	for child in node.get_children():
		result.append_array(_find_mesh_instances(child))
	return result
