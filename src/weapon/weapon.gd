class_name Weapon
extends Node2D

signal weapon_fired

@export var projectile_scene: PackedScene
@export_group("Projectile Pool", "projectile_pool_")
@export var projectile_pool_enabled := true
@export var projectile_pool_size := 10
@export var shoot_delay: float = 0.3
@export var volley_count: int = 1
@export var volley_delay: float = 0.05
@export var use_random_spread := false
@export var min_spread: float = 0
@export var max_spread: float = 20
@export var pellet_count: int = 1
@export var pellet_spread_map: Dictionary[int, float]
## Whether to use aim direction when the shoot action is started
## or each time a projectile is fired.
@export var lock_aim := false

var is_shooting: bool
var target_position := Vector2.RIGHT
var _locked_aim: Vector2
var _projectile_pool: Array[Projectile]
var _projectile_pool_index: int


func _ready() -> void:
    if not projectile_pool_enabled:
        return
    for n in projectile_pool_size:
        _projectile_pool.append(_inst_projectile())


func _can_shoot() -> bool:
    return not is_shooting


# TODO should probably not use awaits
func _shoot() -> void:
    if not _can_shoot():
        return

    _locked_aim = global_position.direction_to(target_position)
    is_shooting = true
    for n in volley_count:
        for pellet_no in pellet_count:
            _launch_projectile(pellet_no)
        weapon_fired.emit()
        if volley_count > 1:
            await get_tree().create_timer(volley_delay).timeout
    await get_tree().create_timer(shoot_delay).timeout
    is_shooting = false


func _inst_projectile() -> Projectile:
    var inst := projectile_scene.instantiate() as Projectile
    inst.using_projectile_pool = projectile_pool_enabled
    return inst


func _launch_projectile(pellet_no: int) -> void:
    var proj: Projectile
    if projectile_pool_enabled:
        proj = _projectile_pool[_projectile_pool_index]
        _projectile_pool_index += 1
        if _projectile_pool_index >= _projectile_pool.size():
            _projectile_pool_index = 0
        proj.remove()
    else:
        proj = _inst_projectile()

    if not proj:
        return

    proj.global_position = global_position

    var dir := _locked_aim
    if not lock_aim:
        dir = global_position.direction_to(target_position)

    var spread: float = 0
    if pellet_no in pellet_spread_map:
        spread = pellet_spread_map[pellet_no]
    elif use_random_spread:
        spread = randf_range(min_spread, max_spread)
        if randf() > 0.5:
            spread *= -1
    proj.direction = dir.rotated(deg_to_rad(spread))

    get_tree().root.add_child(proj)
