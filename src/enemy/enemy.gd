class_name Enemy
extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@export var speed: float = 20
@export var accel: float = 10
@export var move_to_player := true


func _on_health_component_killed() -> void:
    # TODO poof
    remove()


func _physics_process(delta: float) -> void:
    if move_to_player:
        var desired_position := Hero.inst.global_position
        var desired_direction := global_position.direction_to(desired_position)
        velocity = velocity.move_toward(desired_direction * speed, delta * accel)
    move_and_slide()


func _on_health_component_damaged() -> void:
    $Sprite.modulate = Color.WHITE * 30
    var tween = create_tween()
    tween.tween_property($Sprite, "modulate", Color.WHITE, 0.1)


func remove() -> void:
    queue_free()


func _on_hurtbox_dealt_damage() -> void:
    remove()
