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
var from: Node2D
var life_time_timer: Timer

func _init() -> void:
    life_time_timer = Timer.new()
    life_time_timer.autostart
    life_time_timer.one_shot = true
    life_time_timer.wait_time = life_time
    life_time_timer.timeout.connect(_on_life_time_timer_timeout)
    add_child(life_time_timer)

func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _on_life_time_timer_timeout() -> void:
    remove.call_deferred()


func _enter_tree() -> void:
    distance_travelled = 0
    active = true
    current_bounces = 0

    for c in get_children():
        if c is CPUParticles2D:
            c.restart()


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
        remove.call_deferred()

    if bounce_on_edge and current_bounces < max_bounces and global_position.x < -72:
        global_position.x = -72
        direction = direction.bounce(Vector2(-1, 0))
        current_bounces += 1
    if bounce_on_edge and current_bounces < max_bounces and global_position.x > 72:
        global_position.x = 72
        direction = direction.bounce(Vector2(1, 0))
        current_bounces += 1
    if bounce_on_edge and current_bounces < max_bounces and global_position.y < -72:
        global_position.y = -72
        direction = direction.bounce(Vector2(0, 1))
        current_bounces += 1
    if bounce_on_edge and current_bounces < max_bounces and global_position.y > 72:
        global_position.y = 72
        direction = direction.bounce(Vector2(0, -1))
        current_bounces += 1



func remove() -> void:
    if life_time_timer:
        life_time_timer.stop()
    if is_inside_tree():
        get_parent().remove_child(self)
    if not using_projectile_pool:
        queue_free()


func _on_on_screen_notifier_screen_exited() -> void:
    remove.call_deferred()


func _on_body_entered(body: Node2D) -> void:
    if from:
        Combat.damage(body, damage, CombatContext.new(from.duplicate(), direction))
        if remove_after_hit:
            remove.call_deferred()
