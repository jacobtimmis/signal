class_name Projectile
extends Area2D

signal bounced

@export var speed: float = 140
@export var life_time: float = 1.0
@export var use_max_distance := true
@export var max_distance: float = 100
@export var damage: float
@export var remove_after_hit := true
@export var bounce_on_edge := false
@export var max_bounces := 1
@onready var timer: Timer = $Timer

var direction := Vector2(1, 0)
var using_projectile_pool := false
var distance_travelled: float
var active := false
var current_bounces: int
var from: Node2D
var life_time_timer: Timer
var free_on_next_remove := false

func _init() -> void:
    life_time_timer = Timer.new()
    life_time_timer.autostart = true
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
    $Sprite2D.show()
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

    var cam := get_viewport().get_camera_2d()
    var min := cam.global_position - Vector2(72, 72)
    var max := cam.global_position + Vector2(72, 72)
    if bounce_on_edge and current_bounces < max_bounces and global_position.x < min.x:
        global_position.x = min.x
        direction = direction.bounce(Vector2(-1, 0))
        current_bounces += 1
        bounced.emit()
    if bounce_on_edge and current_bounces < max_bounces and global_position.x > max.x:
        global_position.x = max.x
        direction = direction.bounce(Vector2(1, 0))
        current_bounces += 1
        bounced.emit()
    if bounce_on_edge and current_bounces < max_bounces and global_position.y < min.y:
        global_position.y = min.y
        direction = direction.bounce(Vector2(0, 1))
        current_bounces += 1
        bounced.emit()
    if bounce_on_edge and current_bounces < max_bounces and global_position.y > max.y:
        global_position.y = max.y
        direction = direction.bounce(Vector2(0, -1))
        current_bounces += 1
        bounced.emit()



func remove() -> void:
    active = false
    $Sprite2D.hide()
    if $Trail:
        $Trail.emitting = false
    if life_time_timer:
        life_time_timer.stop()
    if is_inside_tree():
        get_parent().remove_child(self)
    if not using_projectile_pool or free_on_next_remove:
        queue_free()


func _on_on_screen_notifier_screen_exited() -> void:
    remove.call_deferred()


func _on_body_entered(body: Node2D) -> void:
    var context := CombatContext.new()
    if from:
        context.from = from
    context.attack_direction = direction
    var res := Combat.damage(body, damage, context)
    if res and remove_after_hit:
        remove.call_deferred()
