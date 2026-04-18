class_name Weapon
extends Node2D

signal weapon_fired

@export var projectile_pool_enabled := true
@export var projectile_pool_size := 10
@export var data: WeaponData

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
    if not data:
        return
    if not _can_shoot():
        return

    _locked_aim = global_position.direction_to(target_position)
    is_shooting = true
    for n in data.volley_count:
        for pellet_no in data.pellet_count:
            _launch_projectile(pellet_no)
        weapon_fired.emit()
        if data.volley_count > 1:
            await get_tree().create_timer(data.volley_delay).timeout
    await get_tree().create_timer(data.shoot_delay).timeout
    is_shooting = false


func _inst_projectile() -> Projectile:
    if not data:
        return

    var inst := data.projectile_scene.instantiate() as Projectile
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
    if not data.lock_aim:
        dir = global_position.direction_to(target_position)

    proj.direction = dir.rotated(data.get_spread(pellet_no))

    get_node("/root/Main/Viewport/Game/ProjectileLayer").add_child(proj)
