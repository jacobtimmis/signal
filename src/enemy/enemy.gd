class_name Enemy
extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent


func _on_health_component_killed() -> void:
    queue_free()
