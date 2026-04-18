class_name HealthComponent
extends Node

signal killed
signal damaged

@export var max_health: float = 100

var current_health: float:
    set = _set_current_health


func _ready() -> void:
    current_health = max_health


func damage(amount: float) -> void:
    current_health -= amount
    damaged.emit()


func _set_current_health(value: float) -> void:
    current_health = clampf(value, 0, max_health)
    if current_health <= 0:
        killed.emit()
