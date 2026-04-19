class_name HealthComponent
extends Node

signal killed
signal damaged(amount: float, context: CombatContext)

@export var max_health: float = 100

var current_health: float:
    set = _set_current_health


func _ready() -> void:
    current_health = max_health


func is_dead() -> bool:
    return current_health <= 0


func kill() -> void:
    current_health = 0


func damage(amount: float, context: CombatContext) -> void:
    if is_dead():
        return
    current_health -= amount
    damaged.emit(amount, context)

func percent() -> float:
    return current_health / max_health


func _set_current_health(value: float) -> void:
    current_health = clampf(value, 0, max_health)
    if current_health <= 0:
        killed.emit()
