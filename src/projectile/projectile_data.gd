class_name ProjectileData
extends Resource

@export var initial_speed: float = 100
@export var max_speed: float = 100
@export var damping: float = 0
@export var gravity := Vector2.ZERO
@export_group("Bounce", "bounce_")
@export var bounce_enabled := false
@export var bounce_max_count: int = 1
@export_range(0, 1, 0.01, "or_greater") var bounce_coefficient: float = 1
@export_group("Friction", "friction_")
@export var friction_enabled := false
@export_range(0, 1, 0.01, "or_greater") var friction_coefficient: float = 1
@export_group("Max Duration", "max_duration_")
@export var max_duration_enabled := true
@export var max_duration_value: float = 1
@export_group("Max Distance", "max_distance_")
@export var max_distance_enabled := true
@export var max_distance_value: float = 100
