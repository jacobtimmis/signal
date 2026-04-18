class_name Projectile
extends Area2D

@export var speed: float = 140
@export var life_time: float = 1.0
@export var use_max_distance := true
@export var max_distance: float = 100
@export var damage: float
@export var remove_after_hit := true
@export var bounce_on_edge := false
@export var max_bounces := 1

var direction := Vector2(1, 0)
var using_projectile_pool := false
var distance_travelled: float
var active := false
var current_bounces: int


func _ready() -> void:
    body_entered.connect(_on_body_entered)


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

    # TODO: this sometimes loses projectiles (maybe if they go too far?)
    if bounce_on_edge and current_bounces < max_bounces and global_position.x < -72:
        direction = direction.bounce(Vector2(-1, 0))
        current_bounces += 1
    if bounce_on_edge and current_bounces < max_bounces and global_position.x > 72:
        direction = direction.bounce(Vector2(1, 0))
        current_bounces += 1
    if bounce_on_edge and current_bounces < max_bounces and global_position.y < -72:
        direction = direction.bounce(Vector2(0, 1))
        current_bounces += 1
    if bounce_on_edge and current_bounces < max_bounces and global_position.y > 72:
        direction = direction.bounce(Vector2(0, -1))
        current_bounces += 1



func remove() -> void:
    if is_inside_tree():
        get_parent().remove_child.call_deferred(self)
    if not using_projectile_pool:
        queue_free()


func _on_on_screen_notifier_screen_exited() -> void:
    remove()


func _on_body_entered(body: Node2D) -> void:
    Combat.damage(body, damage)
    if remove_after_hit:
        remove()
