class_name Hurtbox extends Area2D

signal dealt_damage

@export var damage: float = 10


func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    Combat.damage(body, damage)
    dealt_damage.emit()
