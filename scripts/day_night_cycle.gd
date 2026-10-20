class_name DayNightCycle
extends DirectionalLight3D

@export var day_duration: float = 600.0
@export var night_duration: float = 300.0

var elapsed: float = 0.0
var angle: float = 0.0
var day_number: int = 1

@export var day_color: Color = Color(1.0, 0.96, 0.88)
@export var sunset_color: Color = Color(1.0, 0.55, 0.3)
@export var night_color: Color = Color(0.55, 0.6, 0.75)

@export var day_energy: float = 0.18
@export var night_energy: float = 0.35

@export var sky_top_day: Color = Color(0.35, 0.55, 0.85)
@export var sky_horizon_day: Color = Color(0.75, 0.85, 0.95)
@export var sky_top_night: Color = Color(0.12, 0.14, 0.22)
@export var sky_horizon_night: Color = Color(0.18, 0.19, 0.26)

@export var ambient_energy_night: float = 1.0
@export var ambient_energy_day: float = 1.1

@onready var world_environment: WorldEnvironment = get_tree().get_first_node_in_group("world_environment") as WorldEnvironment

func _ready() -> void:
	add_to_group("day_night_cycle")

func _process(delta: float) -> void:
	var cycle_length := day_duration + night_duration
	var new_elapsed := elapsed + delta
	if new_elapsed >= cycle_length:
		day_number += 1
	elapsed = fmod(new_elapsed, cycle_length)

	if elapsed < day_duration:
		angle = (elapsed / day_duration) * PI
	else:
		angle = PI + ((elapsed - day_duration) / night_duration) * PI

	rotation.x = angle - PI / 2.0

	var height := sin(angle)
	var day_factor := clampf(height, 0.0, 1.0)
	var horizon_factor := 1.0 - clampf(absf(height) / 0.25, 0.0, 1.0)

	light_energy = lerpf(night_energy, day_energy, day_factor)
	var base_color := night_color.lerp(day_color, day_factor)
	light_color = base_color.lerp(sunset_color, horizon_factor)

	if world_environment == null:
		return
	var sky_material := world_environment.environment.sky.sky_material as ProceduralSkyMaterial
	if sky_material == null:
		return
	sky_material.sky_top_color = sky_top_night.lerp(sky_top_day, day_factor)
	sky_material.sky_horizon_color = sky_horizon_night.lerp(sky_horizon_day, day_factor)
	world_environment.environment.ambient_light_color = base_color
	world_environment.environment.ambient_light_energy = lerpf(ambient_energy_night, ambient_energy_day, day_factor)
