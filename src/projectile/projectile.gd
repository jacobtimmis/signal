class_name Projectile
extends Area2D

signal hit(position: Vector2, normal: Vector2, collider: Object)

@export var speed: float = 140
@export var life_time: float = 1.0
@export var use_max_distance := true
@export var max_distance: float = 100

var direction := Vector2(1, 0)
var using_projectile_pool := false
var distance_travelled: float
var active := false


func _enter_tree() -> void:
    distance_travelled = 0
    active = true
    await get_tree().create_timer(life_time).timeout
    remove()


func _process(delta: float) -> void:
    if not active:
        return

    direction = direction.normalized()

    var old_position := position

    var move_this_frame := direction * speed * delta
    position += move_this_frame

    var position_delta := position - old_position
    distance_travelled += position_delta.length()
    if use_max_distance and distance_travelled > max_distance:
        remove()


func remove() -> void:
    if is_inside_tree():
        get_parent().remove_child(self)
    if not using_projectile_pool:
        queue_free()


func _on_on_screen_notifier_screen_exited() -> void:
    remove()
