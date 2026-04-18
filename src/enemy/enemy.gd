class_name Enemy
extends CharacterBody2D

const ENEMY_DEATH_POOF = preload("uid://dk2e305fr72tw")

@onready var health_component: HealthComponent = $HealthComponent
@export var speed: float = 20
@export var speed_change: float = 10
@export var move_to_player := true
@export var far_distance_to_player: float = 0
@export var close_distance_to_player: float = 0
@export var hit_knockback: float = 10


func _on_health_component_killed() -> void:
    var inst := ENEMY_DEATH_POOF.instantiate()
    inst.global_transform = global_transform
    get_parent().add_child(inst)

    remove()


func _physics_process(delta: float) -> void:
    if move_to_player:
        var desired_position := Hero.inst.global_position
        var desired_direction := global_position.direction_to(desired_position)
        var dist := global_position.distance_to(desired_position)
        if dist < close_distance_to_player:
            print("sfdas")
            desired_direction *= -1
        if dist > far_distance_to_player or dist < close_distance_to_player:
            velocity = velocity.move_toward(desired_direction * speed, delta * speed_change)
        else:
            velocity = velocity.move_toward(Vector2.ZERO, delta * speed_change)
    move_and_slide()


func _on_health_component_damaged(amount: float, context: CombatContext) -> void:
    $Sprite.modulate = Color.WHITE * 30
    var tween = create_tween()
    tween.tween_property($Sprite, "modulate", Color.WHITE, 0.1)
    velocity = context.attack_direction * hit_knockback
    $HitSound.play()


func remove() -> void:
    queue_free()


func _on_hurtbox_dealt_damage() -> void:
    remove()
