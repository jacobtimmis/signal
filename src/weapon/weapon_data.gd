class_name WeaponData
extends Resource

@export var projectile_scene: PackedScene
@export var shoot_delay: float = 0.3
@export var volley_count: int = 1
@export var volley_delay: float = 0.05
@export var use_random_spread := false
@export var min_spread: float = 0
@export var max_spread: float = 20
@export var even_spread_enabled := false
@export var even_spread_angle: float = 45.0
@export var pellet_count: int = 1
@export var pellet_spread_map: Dictionary[int, float]
## Whether to use aim direction when the shoot action is started
## or each time a projectile is fired.
@export var lock_aim := false


func get_spread(pellet_no: int) -> float:
    var spread: float = 0
    if pellet_no in pellet_spread_map:
        spread = pellet_spread_map[pellet_no]
    elif even_spread_enabled and pellet_count > 1:
        spread = -even_spread_angle / 2.0 + (even_spread_angle / (pellet_count - 1)) * pellet_no
    elif use_random_spread:
        spread = randf_range(min_spread, max_spread)
        if randf() > 0.5:
            spread *= -1
    return deg_to_rad(spread)
