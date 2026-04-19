class_name Enemy
extends CharacterBody2D
const PICKUP = preload("uid://dp7osbi4hyudh")

@onready var health_component: HealthComponent = $HealthComponent
@export var speed: float = 20
@export var speed_change: float = 10
@export var move_to_player := true
@export var far_distance_to_player: float = 0
@export var close_distance_to_player: float = 0
@export var hit_knockback: float = 10
@export var weapon: Weapon
@export var weapon_dist: float = 100
@export var death_poof := preload("uid://dk2e305fr72tw")
@export var score_value: int = 10
@export var contributes_to_heat := true
@export var chance_to_spawn_pickup := 0.0
@export var stop_while_shooting := false
@export var go_to_center := false
@export var always_flee := false
var add_score := true
@onready var on_screen_notifier: VisibleOnScreenNotifier2D = $OnScreenNotifier
@export var play_hit_effects := true
var is_spawning := true


func _ready() -> void:
    await get_tree().create_timer(0.5).timeout
    is_spawning = false


func _on_health_component_killed() -> void:
    var inst := death_poof.instantiate() as Node2D
    inst.global_transform = global_transform
    get_node("/root/Main/Viewport/Game/SplatterLayer").add_child(inst)

    if add_score:
        ScoreManager.add_score(score_value)
        if contributes_to_heat:
            Spawner.inst.current_heat += 1
            ScoreManager.inst.xp += 1
        if randf() <= chance_to_spawn_pickup:
            var pickup = PICKUP.instantiate()
            pickup.global_transform = global_transform
            get_parent().add_child.call_deferred(pickup)
    remove()


func _physics_process(delta: float) -> void:
    if is_spawning:
        return

    var desired_position := Hero.inst.global_position
    if go_to_center:
        desired_position = Vector2.ZERO
    var desired_direction := global_position.direction_to(desired_position)
    var dist := global_position.distance_to(desired_position)
    var center_dist := global_position.distance_to(Vector2.ZERO)

    if weapon:
        weapon.target_position = Hero.inst.global_position
        if dist < weapon_dist and not Hero.inst.health_component.is_dead() and on_screen_notifier.is_on_screen() and center_dist < 60:
            weapon._shoot()

    if weapon and stop_while_shooting and weapon.is_shooting:
        velocity = Vector2.ZERO
    if Hero.inst.health_component.is_dead() and (always_flee or not go_to_center):
        velocity = desired_direction * speed * -1
    elif move_to_player:
        if dist < close_distance_to_player:
            desired_direction *= -1
        if dist > far_distance_to_player or dist < close_distance_to_player:
            var speed_to_use := speed
            #if center_dist > 60:
                #speed_to_use *= 4
            velocity = velocity.move_toward(desired_direction * speed_to_use, delta * speed_change)
        else:
            velocity = velocity.move_toward(Vector2.ZERO, delta * speed_change)
    move_and_slide()


func _on_health_component_damaged(amount: float, context: CombatContext) -> void:
    var center_dist := global_position.distance_to(Vector2.ZERO)
    if center_dist < 55:
        velocity = context.attack_direction * hit_knockback

    if play_hit_effects:
        $Sprite.modulate = Color.WHITE * 30
        var tween = create_tween()
        tween.tween_property($Sprite, "modulate", Color.WHITE, 0.1)
        $HitSound.play()
        GameCamera.shake(2, 20)


func remove() -> void:
    queue_free()


func _on_hurtbox_dealt_damage() -> void:
    add_score = false
    health_component.kill()
